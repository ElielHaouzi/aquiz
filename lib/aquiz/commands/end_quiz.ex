defmodule AQuiz.Command.EndQuiz do
  @behaviour Command

  def display() do
    {:ok, "Stop the quiz"}
  end

  def execute() do
    {:error, ""}
  end
end
