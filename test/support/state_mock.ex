defmodule HTTPMock.StateMockTest do
  use HTTPMock.State

  entity(:users, default: [{1, "fulano"}], key: 0)
  entity(:profiles, default: [%{id: 1, type: "human"}], key: :id)
end
