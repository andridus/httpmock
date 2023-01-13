defmodule HttpmockTest do
  use ExUnit.Case
  use Mimic

  test "greets the world" do
    Mimic.stub_with(HTTPoison, HTTPMock.APIMockTest)

    return =
      ~s({\n  "userId": 1,\n  "id": 1,\n  "title": "delectus aut autem",\n  "completed": false\n})

    assert {:ok,
            %{
              body: ^return,
              status_code: 200
            }} = HTTPoison.get("https://jsonplaceholder.typicode.com/todos/1")

    return =
      ~s({\n  "id": 1,\n  "name": "Leanne Graham",\n  "username": "Bret",\n  "email": "Sincere@april.biz",\n  "address": {\n    "street": "Kulas Light",\n    "suite": "Apt. 556",\n    "city": "Gwenborough",\n    "zipcode": "92998-3874",\n    "geo": {\n      "lat": "-37.3159",\n      "lng": "81.1496"\n    }\n  },\n  "phone": "1-770-736-8031 x56442",\n  "website": "hildegard.org",\n  "company": {\n    "name": "Romaguera-Crona",\n    "catchPhrase": "Multi-layered client-server neural-net",\n    "bs": "harness real-time e-markets"\n  }\n})

    assert {:ok,
            %{
              body: ^return,
              status_code: 200
            }} = HTTPoison.get("https://jsonplaceholder.typicode.com/users/1")
  end

  test "match get with params" do
    Mimic.stub_with(HTTPoison, HTTPMock.APIMockTest)

    assert {:ok, %{status_code: 200}} =
             HTTPoison.get("https://jsonplaceholder.typicode.com/todos?limit=1")
  end
end
