defmodule Aquiz.Application do
  @moduledoc false

  use Application

  def start(_type, num_of_questions) do
    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: Aquiz.Worker.start_link(arg)
      # {Aquiz.Worker, arg},
      {Aquiz.Quiz, num_of_questions},
      {Aquiz.TriviaServer, []}
    ]

    opts = [strategy: :one_for_one, name: Aquiz.TopLevelSupervisor]
    Supervisor.start_link(children, opts)
  end
end
