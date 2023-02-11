defmodule HTTPMock.State.Supervisor do
    def start_link(children) do
    Supervisor.start_link(__MODULE__, children, [])
  end

  def init(children \\ []) do
    Supervisor.init(children, strategy: :one_for_one)
  end
end