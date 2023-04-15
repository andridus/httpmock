# HTTPMock

## Installation

```elixir
def deps do
  [
    {:httpmock, "~> 0.1.5"}
  ]
end
```

### Using

1. Create a router with mocked endpoint in `test/support`

```elixir
defmodule Myapp.APIMockTest do
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
### With mimic

2. Using [Mimic](https://github.com/edgurgel/mimic) to mimetize HTTPoison in `test/test_helper.exs`

```elixir
  Mimic.copy(HTTPoison)
  ExUnit.start()
```

3. use the mimic

```elixir

  test "greets the world" do
    Mimic.stub_with(HTTPoison, Myapp.APIMockTest)
    assert {:ok, %{ status_code: 200}} = HTTPoison.get("https://jsonplaceholder.typicode.com/todos/1")
  end

```

### Without mimic

2. Set on top of you module @httpoison const to get env from test.exs

in your file that use httpoison
```elixir
defmodule MyappWeb.Api.Client do
  @moduledoc """
    Myapp Web Api Client
  """
  @httpoison Application.compile_env(:myapp, :httpoison, HTTPoison)

  def get_todo(id) do
    @httpoison.get("https://jsonplaceholder.typicode.com/todos/#{id}")
    ## instead of
    # HTTPoison.get("https://jsonplaceholder.typicode.com/todos/#{id}")

  end
end
```

3. set env in your config/test.exs

```elixir
  .
  .
  .
  config :myapp, :httpoison, Myapp.APIMockTest

```

4. Use on test

```elixir

  test "greets the world" do
    assert {:ok, %{ status_code: 200}} = MyappWeb.Api.Client.get_todos(1)
  end

```

### HTTPMock.State

The HTTPMock.State manage the state for your mocked api.

1. Set the state  in `test/support/my_state.ex` (my_state.ex is an example of namefile)

```elixir
  defmodule Myapp.MyState do
    use HTTPMock.State
    entity(:todos, default: [], key: :id) ## the field :id is required by now
  end
```

The behaviour HTTPMock.state provide functions to manager state of 'table'
 - all()
 - all(entity)
 - one(entity, id)
 - create(entity, params)
 - delete(entity, id)
 - update(entity, id, params)
 - reset()

 The `reset()` function should be called in setup, before tests, to cleaning state.

 ### Create a new record

 ```elixir
   :ok = Myapp.MyState.create(:todos, %{id: "uuid", title: "my_title"}) ## the only :id field is required. The other fields, follow your needs
 ```

 I prefer create a new function on Myapp.MyState, because native create function return :ok, and then I want to return the last created record.

 ```elixir
   defmodule Myapp.MyState do

    ...

    def new(params) do
      id = "uuid_generated"
      create(:todos, %{id: id, title: "my_title"})
      one(:todos, id)
    end
 ```

 ### Get a previous record
  with the Id of record

 ```elixir
   returned_element= Myapp.MyState.one(:todos,id) ## or nil
 ```

 ### Update a previous record
  with the Id of record

 ```elixir
   :ok = Myapp.MyState.update(:todos, id, %{title: "updated title"})
 ```

 ### Delete a previous record
  with the Id of record

 ```elixir
   :ok = Myapp.MyState.delete(:todos, id)
 ```

 ### Get all from table
  with the Id of record

 ```elixir
   :ok = Myapp.MyState.all(:todos)
 ```

 ### Get all from all state
  with the Id of record

 ```elixir
   :ok = Myapp.MyState.all()
 ```

2. Set the HTTPMock.State on Supervisor on test/test_helper.exs.
  We provide the `HTTPMock.State.Supervisor`

  in test/test_helper.exs
  ```elixir

    HTTPMock.State.Supervisor.start_link([Myapp.MyState])

  ```

3. Using in your mocked router or in your tests,  (rememeber that apply reset before tests)
in any file, like test/myapp/some_test.exs

```elixir
  defmodule Myapp.SomeTest do
  ...
    describe "some test" do
      setup do
        Myapp.MyState.reset()
      end
      test "testing something" do
        assert :ok = Myapp.MyState.create(:todos, %{id: "uuid", title: "my_title"})
        assert {:ok, %{body: json_encoded, status_code: 200 } } = MyappWeb.Api.Client.get_todos(1)
        assert %{id: "uuid", title: "my_title"} = Jason.decode!(json_encoded)}
      end
    end
  end
```

in mock route, update to use the state
```elixir
defmodule Myapp.APIMockTest do
  @moduledoc """
    Mock Api
  """
  use HTTPMock, behaviour: :httpoison

  endpoint "https://jsonplaceholder.typicode.com" do
    get "/todos/:id", __MODULE__, :get_todo
  end

  def get_todo(_conn, %{"id" => id}) do
    returned_element= Myapp.MyState.one(:todos,id)
    data = returned_element |> Jason.encode!() ## Example using jason
    {:ok, %{body: data, status_code: 200} }
  end
  ...
end
```

 That is it.
