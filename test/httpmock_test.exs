defmodule HttpmockTest do
  use ExUnit.Case
  use Mimic

  describe "basic tests" do
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

    test "match post with params" do
      Mimic.stub_with(HTTPoison, HTTPMock.APIMockTest)

      assert {:ok, %{body: "{\"data\":\"user\"}", status_code: 200}} =
              HTTPoison.post("https://jsonplaceholder.typicode.com/users", ~s({"data": "user"}))
    end

    test "match put with params" do
      Mimic.stub_with(HTTPoison, HTTPMock.APIMockTest)

      assert {:ok, %{body: "{\"data\":\"user\"}", status_code: 200}} =
              HTTPoison.put("https://jsonplaceholder.typicode.com/users", ~s({"data": "user"}))
    end
  end

  describe "tests with state" do
    setup do
      {:ok, _pid} = HTTPMock.StateMockTest.start_link()


      :ok
    end
    test "Testing state" do
      assert [{1, "fulano"}] = HTTPMock.StateMockTest.all(:users)
      assert [%{id: 1, type: "human"}] = HTTPMock.StateMockTest.all(:profiles)
      assert %{id: 1, type: "human"} = HTTPMock.StateMockTest.one(:profiles, 1)
      assert {1, "fulano"} = HTTPMock.StateMockTest.one(:users, 1)
      refute HTTPMock.StateMockTest.one(:users, 2)
      assert :ok = HTTPMock.StateMockTest.update(:users, 1, {1, "de Tal"})
      assert {1, "de Tal"} = HTTPMock.StateMockTest.one(:users, 1)
      assert :ok = HTTPMock.StateMockTest.create(:users, {2, "Sicrano"})
      assert {1, "de Tal"} = HTTPMock.StateMockTest.one(:users, 1)
    end
    test "match get user" do
      Mimic.stub_with(HTTPoison, HTTPMock.APIMockTest)

      assert {:ok, %{body: body, status_code: 200}} =
              HTTPoison.get("https://jsonplaceholder.typicode.com/profiles/mock/1")

      assert %{id: 1, type: "human"} = body
    end

    test "match put with params" do
      Mimic.stub_with(HTTPoison, HTTPMock.APIMockTest)

      data = %{file: "nofile"} |> JSON.encode!()
      assert {:ok, %{body: %{:id => 1, :type => "human", "file" => "nofile", "id" => "1"}, status_code: 200}} =
              HTTPoison.put("https://jsonplaceholder.typicode.com/profiles/mock/1", data)
    end
  end


end
