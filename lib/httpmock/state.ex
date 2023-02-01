defmodule HTTPMock.State do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      use GenServer
      Module.register_attribute(__MODULE__, :entities, accumulate: true)
      @before_compile HTTPMock.State
      import HTTPMock.State
      require HTTPMock.State

      def init(state) do
        {:ok, state}
      end

      def handle_call("all:" <> entity, _, state) do
        entity = String.to_existing_atom(entity)
        {_, entity_state} = List.keyfind(state, entity, 0, {entity, [state: []]})

        {:reply, entity_state[:default], state}
      end

      def handle_call({"one:" <> entity, id}, _, state) do
        entity = String.to_existing_atom(entity)
        entity_state = state[entity]
        {_, entity_state} = List.keyfind(state, entity, 0, {entity, [state: [], key: :id]})
        key = entity_state[:key]

        finded =
          cond do
            is_number(key) ->
              List.keyfind(entity_state[:state], id, key)

            is_atom(key) or is_binary(key) ->
              Enum.find(
                entity_state[:state],
                fn map when is_map(map) -> map[key] == id end
              )

            :else ->
              :key_valid
          end

        {:reply, finded, state}
      end

      def handle_call({"create:" <> entity, params}, _, state) do
        entity = String.to_existing_atom(entity)
        entity_state = state[entity]
        {_, entity_state} = List.keyfind(state, entity, 0, {entity, [state: [], key: :id]})
        key = entity_state[:key]

        {result, entity_state} =
          cond do
            is_number(key) && is_tuple(params) ->
              {:ok, [params | entity_state[:state] |> :lists.reverse()] |> :lists.reverse()}

            (is_atom(key) or is_binary(key)) and is_map(params) and !is_nil(params[key]) ->
              {:ok, [params | entity_state[:state] |> :lists.reverse()] |> :lists.reverse()}

            :else ->
              {:key_or_params_valid, state}
          end

        state =
          Keyword.update(state, entity, entity_state, fn attrs ->
            Keyword.update(attrs, :state, attrs[:state], fn _ -> entity_state end)
          end)

        {:reply, result, state}
      end

      def handle_call({"delete:" <> entity, id}, _, state) do
        entity = String.to_existing_atom(entity)
        entity_state = state[entity]
        {_, entity_state} = List.keyfind(state, entity, 0, {entity, [state: [], key: :id]})
        key = entity_state[:key]

        {result, entity_state} =
          cond do
            is_number(key) ->
              {:ok,
               Enum.filter(entity_state[:state], fn row ->
                 elem(row, key) != id
               end)}

            is_atom(key) or is_binary(key) ->
              {:ok,
               Enum.map(
                 entity_state[:state],
                 fn row when is_map(row) ->
                   row[key] != id
                 end
               )}

            :else ->
              {:key_or_params_valid, state}
          end

        state =
          Keyword.update(state, entity, entity_state, fn attrs ->
            Keyword.update(attrs, :state, attrs[:state], fn _ -> entity_state end)
          end)

        {:reply, :ok, state}
      end

      def handle_call({"update:" <> entity, id, params}, _, state) do
        entity = String.to_existing_atom(entity)
        entity_state = state[entity]
        {_, entity_state} = List.keyfind(state, entity, 0, {entity, [state: [], key: :id]})
        key = entity_state[:key]

        {result, entity_state} =
          cond do
            is_number(key) and is_tuple(params) ->
              {:ok,
               Enum.map(entity_state[:state], fn row ->
                 if elem(row, key) == id do
                   params
                 else
                   row
                 end
               end)}

            (is_atom(key) or is_binary(key)) and is_map(params) ->
              {:ok,
               Enum.map(
                 entity_state[:state],
                 fn
                   row when is_map(row) ->
                     if row[key] == id do
                       Map.merge(row, params)
                     else
                       row
                     end

                   row ->
                     row
                 end
               )}

            :else ->
              {:key_or_params_valid, state}
          end

        state =
          Keyword.update(state, entity, entity_state, fn attrs ->
            Keyword.update(attrs, :state, attrs[:state], fn _ -> entity_state end)
          end)

        {:reply, result, state}
      end

      # PUBLIC API
      def all(entity) do
        GenServer.call(__MODULE__, "all:#{entity}")
      end

      def one(entity, id) do
        GenServer.call(__MODULE__, {"one:#{entity}", id})
      end

      def create(entity, params) do
        GenServer.call(__MODULE__, {"create:#{entity}", params})
      end

      def delete(entity, id) do
        GenServer.call(__MODULE__, {"delete:#{entity}", id})
      end

      def update(entity, id, params) do
        GenServer.call(__MODULE__, {"update:#{entity}", id, params})
      end
    end
  end

  @doc false
  defmacro __before_compile__(env) do
    entities = Module.get_attribute(env.module, :entities) || []

    quote do
      def start_link do
        state = unquote(entities)
        GenServer.start_link(__MODULE__, state, name: __MODULE__)
      end
    end
  end

  defmacro entity(name, opts \\ []) do
    default = Macro.escape(opts[:default]) || []
    key = opts[:key]

    quote do
      Module.put_attribute(
        __MODULE__,
        :entities,
        {unquote(name), [key: unquote(key), default: unquote(default), state: unquote(default)]}
      )
    end
  end
end
