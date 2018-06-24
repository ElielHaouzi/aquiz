defmodule Aquiz.Cli do
  @num_of_questions 2

  def main(argv) do
    argv
    |> parse_args
    |> start_game
  end

  defp parse_args(args) do
    switches = [help: :boolean]
    parse_args = OptionParser.parse(args, switches: switches)

    case parse_args do
      {[help: true], _, _} ->
        :help

      {[questions: num_of_questions], _, _} ->
        {:start, num_of_questions}

      _ ->
        {:start, @num_of_questions}
    end
  end

  defp start_game(:help) do
    IO.puts("Run the AQuiz from the command line by typing aquiz [--questions num_of_questions].")
  end

  defp start_game({:start, num_of_questions}) do
    Aquiz.Application.start("", num_of_questions)
    run()
  end

  defp run() do
    case Aquiz.Quiz.next() do
      {:error} ->
        display_error()

      false ->
        display_result()

      {:ok, question} ->
        display_question(question)

        user_response = get_response_from_user(question)

        determine_points(user_response, question)

        run()
    end
  end

  defp display_question(question) do
    IO.puts question[:question]
    IO.puts "Hint: #{question[:correct_answer_index]}"

    question[:answers]
    |> Enum.with_index(0)
    |> Enum.map_join("\n", &"#{elem(&1, 1) + 1}. #{elem(&1, 0)}")
    |> IO.puts()
  end

  defp get_response_from_user(question) do
    user_response = IO.gets("Enter the right response: ") |> String.trim() |> String.to_integer()
    # Check user response
    user_response - 1
  end

  defp determine_points(user_response, question) do
    Aquiz.Quiz.set_user_response(question, user_response)
  end

  defp display_error() do
    IO.puts("an error occurred on getting a new question")
  end

  defp display_result() do
    points = Aquiz.Quiz.get_points()
    IO.puts("\nPoints: #{points}")
  end
end
