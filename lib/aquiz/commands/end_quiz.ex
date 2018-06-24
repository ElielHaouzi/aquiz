defmodule AQuiz.Command.EndQuiz do
  @behaviour Command

  def display() do
    {:ok, "Stop the quiz?"}
  end

  def execute(input) do
    display_result()
    {:stop}
  end

  defp display_result() do
    points = Aquiz.Quiz.get_points()
    IO.puts("\nPoints: #{points}")
  end
end
