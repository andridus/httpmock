defmodule HTTPMock do
  @moduledoc """
    Documentation for `HTTPMock`.
  """
  defmacro __using__(opts) do
    behaviour = opts[:behaviour] || :none

    quote do
      Module.register_attribute(__MODULE__, :routes, accumulate: true)
      @behav unquote(behaviour)
      @before_compile HTTPMock
      import HTTPMock
      require HTTPMock
    end
  end

  @doc false
  defmacro __before_compile__(env) do
    routes = Module.get_attribute(env.module, :routes)
    behav = Module.get_attribute(env.module, :behav)

    defs =
      for {method, url, module, function} <- routes do
        list_url =
          url
          |> String.split("/")
          |> Enum.map(fn x ->
            if String.starts_with?(x, ":") do
              v =
                x
                |> String.replace(":", "")
                |> String.to_atom()
                |> Macro.var(nil)

              quote do: unquote(v)
            else
              x
            end
          end)

        params =
          list_url
          |> Enum.reduce([], fn
            {key, _, _} = x, acc -> [{to_string(key), x} | acc]
            _, acc -> acc
          end)

        list_url_formated =
          url
          |> String.split("/")
          |> Enum.map(fn x ->
            if String.starts_with?(x, ":") do
              nil
            else
              x
            end
          end)

        quote do
          def match_route(unquote(method), unquote(list_url), opts) do
            body_params = (opts[:body_params] || %{}) |> HTTPMock.maybe_decode()
            query_params = opts[:query_params] || %{}

            method = unquote(method)
            url = unquote(list_url_formated) |> Enum.join("/")
            path_params = unquote(params) |> Map.new()

            params =
              body_params
              |> Map.merge(query_params)
              |> Map.merge(path_params)

            conn = %{
              url: url,
              req_headers: opts[:headers],
              req_options: opts[:options],
              body_params: body_params,
              path_params: path_params,
              query_params: query_params,
              method: method
            }

            apply(unquote(module), unquote(function), [conn, params])
          end
        end
      end

    default_dipatch =
      quote do
        def match_route(method, list_url, _) do
          url = list_url |> Enum.join("/")
          raise("Route `#{String.upcase(to_string(method))} #{url}` not defined")
        end
      end

    defs = defs ++ [default_dipatch]

    behaviour =
      case behav do
        :httpoison -> HTTPMock.Behaviours.HTTPoison.funs()
        _ -> nil
      end

    quote do
      def match_route(method, list_url), do: match_route(method, list_url, [])
      unquote_splicing(defs)

      def match(_method, _url, _opts \\ [])

      def match(method, url, opts) when is_binary(url) and is_atom(method) do
        {base, params} = HTTPMock.parse_url(url)
        match_route(method, String.split(base, "/"), opts ++ [query_params: params])
      end

      def match(method, url, _),
        do: raise("Route `#{String.upcase(to_string(method))} #{url}` not defined")

      unquote(behaviour)
    end
  end

  def parse_url(url) do
    String.split(url, "?")
    |> case do
      [base, params] -> {base, URI.decode_query(params)}
      _ -> {url, %{}}
    end
  end

  defmacro endpoint(path, do: {:__block__, [], body}), do: do_endpoint(path, body)
  defmacro endpoint(path, do: body), do: do_endpoint(path, body)

  def do_endpoint(path, body) do
    body =
      Macro.postwalk(body, fn
        x when is_bitstring(x) -> {:merge_url, [], [path, x]}
        x -> x
      end)

    quote do
      unquote(body)
    end
  end

  defmacro merge_url(base, path) do
    quote do
      unquote(base) <> unquote(path)
    end
  end

  defmacro get(path, module, function) do
    quote do
      Module.put_attribute(
        __MODULE__,
        :routes,
        {:get, unquote(path), unquote(module), unquote(function)}
      )
    end
  end

  defmacro post(path, module, function) do
    quote do
      Module.put_attribute(
        __MODULE__,
        :routes,
        {:post, unquote(path), unquote(module), unquote(function)}
      )
    end
  end

  defmacro put(path, module, function) do
    quote do
      Module.put_attribute(
        __MODULE__,
        :routes,
        {:put, unquote(path), unquote(module), unquote(function)}
      )
    end
  end

  defmacro delete(path, module, function) do
    quote do
      Module.put_attribute(
        __MODULE__,
        :routes,
        {:delete, unquote(path), unquote(module), unquote(function)}
      )
    end
  end

  def maybe_decode(body) when is_binary(body) do
    JSON.decode(body)
    |> case do
      {:ok, body} -> body
      _ -> %{}
    end
  end

  def maybe_decode(body) when is_map(body), do: body
end
