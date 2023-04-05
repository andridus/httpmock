defmodule HTTPMock.APIMockTest do
  @moduledoc """
    Mock Api
  """
  use HTTPMock, behaviour: :httpoison

  @url "https://jsonplaceholder.typicode.com"
  endpoint @url do
    get("/todos", __MODULE__, :get_todos)
    get("/todos/:id", __MODULE__, :get_todo)
    get("/users/:id", __MODULE__, :get_user)
    post("/users", __MODULE__, :post_user)
    put("/users", __MODULE__, :put_user)
    get("/profiles/mock/:id", __MODULE__, :get_profile_mock)
    put("/profiles/mock/:id", __MODULE__, :put_profile_mock)
  end

  def get_todos(_conn, %{"limit" => _}) do
    data =
      ~s([{\n  \"userId\": 1,\n  \"id\": 1,\n  \"title\": \"delectus aut autem\",\n  \"completed\": false\n}])

    {:ok, %{body: data, status_code: 200}}
  end

  def get_todo(_conn, %{"id" => id}) do
    data =
      ~s({\n  \"userId\": #{id},\n  \"id\": #{id},\n  \"title\": \"delectus aut autem\",\n  \"completed\": false\n})

    {:ok, %{body: data, status_code: 200}}
  end

  def get_user(_conn, %{"id" => _id}) do
    data =
      "{\n  \"id\": 1,\n  \"name\": \"Leanne Graham\",\n  \"username\": \"Bret\",\n  \"email\": \"Sincere@april.biz\",\n  \"address\": {\n    \"street\": \"Kulas Light\",\n    \"suite\": \"Apt. 556\",\n    \"city\": \"Gwenborough\",\n    \"zipcode\": \"92998-3874\",\n    \"geo\": {\n      \"lat\": \"-37.3159\",\n      \"lng\": \"81.1496\"\n    }\n  },\n  \"phone\": \"1-770-736-8031 x56442\",\n  \"website\": \"hildegard.org\",\n  \"company\": {\n    \"name\": \"Romaguera-Crona\",\n    \"catchPhrase\": \"Multi-layered client-server neural-net\",\n    \"bs\": \"harness real-time e-markets\"\n  }\n}"

    {:ok, %{body: data, status_code: 200}}
  end

  def get_profile_mock(_conn, %{"id" => id} = _params) do
    data = HTTPMock.StateMockTest.one(:profiles, String.to_integer(id))

    {:ok, %{body: data, status_code: 200}}
  end

  def put_profile_mock(_conn, %{"id" => id} = params) do
    :ok = HTTPMock.StateMockTest.update(:profiles, String.to_integer(id), params)
    data = HTTPMock.StateMockTest.one(:profiles, String.to_integer(id))
    {:ok, %{body: data, status_code: 200}}
  end

  def post_user(_conn, params) do
    {:ok, %{body: JSON.encode!(params), status_code: 200}}
  end

  def put_user(_conn, params) do
    {:ok, %{body: JSON.encode!(params), status_code: 200}}
  end
end
