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
