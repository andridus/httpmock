defmodule HTTPMock.Behaviours.HTTPoison do
  @moduledoc """
  Documentation for `HTTPMock`.
  """
  def funs do
    quote do
      def unwrap({:ok, response}), do: response
      def unwrap({:error, response}), do: raise("request error")

      def delete(url, headers \\ [], options \\ []),
        do: match(:delete, url, headers: headers, options: options)

      def delete!(url, headers \\ [], options \\ []),
        do: match(:delete, url, headers: headers, options: options) |> unwrap()

      def get(url, headers \\ [], options \\ []),
        do: match(:get, url, headers: headers, options: options)

      def get!(url, headers \\ [], options \\ []),
        do: match(:get, url, headers: headers, options: options) |> unwrap()

      def head(url, headers \\ [], options \\ []),
        do: match(:head, url, headers: headers, options: options)

      def head!(url, headers \\ [], options \\ []),
        do: match(:head, url, headers: headers, options: options) |> unwrap()

      def options(url, headers \\ [], options \\ []),
        do: match(:options, url, headers: headers, options: options)

      def options!(url, headers \\ [], options \\ []),
        do: match(:options, url, headers: headers, options: options) |> unwrap()

      def patch(url, headers \\ [], options \\ []),
        do: match(:patch, url, headers: headers, options: options)

      def patch!(url, headers \\ [], options \\ []),
        do: match(:patch, url, headers: headers, options: options) |> unwrap()

      def post(url, body, headers \\ [], options \\ []),
        do: match(:post, url, headers: headers, options: options, body_params: body)

      def post!(url, body, headers \\ [], options \\ []),
        do: match(:post, url, headers: headers, options: options, body_params: body) |> unwrap()

      def put(url, body \\ "", headers \\ [], options \\ []),
        do: match(:put, url, headers: headers, options: options, body_params: body)

      def put!(url, body \\ "", headers \\ [], options \\ []),
        do:
          match(:put, url, headers: headers, options: options, body_params: body)
          |> unwrap()
    end
  end
end
