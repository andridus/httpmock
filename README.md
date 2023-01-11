# Httpmock

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `httpmock` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:httpmock, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/httpmock>.


### Using

1. Create a router with mocked endpoint in `test/support`

```elixir
defmodule HTTPMock.APIMockTest do
  @moduledoc """
    Mock Api
  """
  use HTTPMock, behaviour: :httpoison

  endpoint "https://jsonplaceholder.typicode.com" do
    get "/todos/:id", __MODULE__, :get_todo
    get "/users/:id", __MODULE__, :get_user
  end

  def get_todo(_conn, %{"id" => id}) do
    data = ~s({\n  \"userId\": #{id},\n  \"id\": #{id},\n  \"title\": \"delectus aut autem\",\n  \"completed\": false\n})
    {:ok, %{body: data, status_code: 200}}
  end
  def get_user(_conn, %{"id" => id}) do
    data = ~s({\n  "id": #{id},\n  "name": "Leanne Graham",\n  "username": "Bret",\n  "email": "Sincere@april.biz",\n  "address": {\n    "street": "Kulas Light",\n    "suite": "Apt. 556",\n    "city": "Gwenborough",\n    "zipcode": "92998-3874",\n    "geo": {\n      "lat": "-37.3159",\n      "lng": "81.1496"\n    }\n  },\n  "phone": "1-770-736-8031 x56442",\n  "website": "hildegard.org",\n  "company": {\n    "name": "Romaguera-Crona",\n    "catchPhrase": "Multi-layered client-server neural-net",\n    "bs": "harness real-time e-markets"\n  }\n})
    {:ok, %{body: data, status_code: 200}}
  end
end

```
2. Using [Mimic](https://github.com/edgurgel/mimic) to mimetize HTTPoison in `test/test_helper.exs`

```elixir
  Mimic.copy(HTTPoison)
  ExUnit.start()
```

3. use the mimic

```elixir

  test "greets the world" do
    Mimic.stub_with(HTTPoison, HTTPMock.APIMockTest)
    assert {:ok, %{ status_code: 200}} = HTTPoison.get("https://jsonplaceholder.typicode.com/todos/1")
  end

```
