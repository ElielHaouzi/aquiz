defmodule Aquiz.Quiz do
  use GenServer

  defmodule State do
    defstruct position: 0, correct_answers: 0, num_of_questions: 0
  end

  #
  # API
  #
  def start_link(num_of_questions) do
    GenServer.start_link(__MODULE__, num_of_questions, name: __MODULE__)
  end

  # def has_next do
  #   GenServer.call(__MODULE__, :has_next)
  # end

  def next do
    GenServer.call(__MODULE__, :next)
  end

  def set_user_response(question, user_response) do
    GenServer.call(__MODULE__, {:set_user_response, question, user_response})
  end

  def get_points() do
    GenServer.call(__MODULE__, :get_points)
  end

  #
  # Callbacks
  #
  def init(num_of_questions) when is_integer(num_of_questions) do
    {:ok, %State{num_of_questions: num_of_questions}}
  end

  def init(_) do
    {:ok, %State{}}
  end

  def handle_call(:next, _from, %State{position: position, num_of_questions: noq} = state)
      when position < noq do
    result = Aquiz.TriviaServer.get_question()

    case result do
      :error ->
        {:reply, {:error}, state}

      question ->
        question = format_question(question)
        {:reply, {:ok, question}, %{state | position: position + 1}}
    end
  end

  def handle_call(:next, _from, state), do: {:reply, false, state}

  def handle_call(
        {:set_user_response, question, user_response},
        _from,
        %{correct_answers: correct_answers} = state
      ) do
    case question[:correct_answer_index] == user_response do
      true -> {:reply, :ok, %{state | correct_answers: correct_answers + 1}}
      false -> {:reply, :ok, state}
    end
  end

  def handle_call(:get_points, _from, %{num_of_questions: num_of_questions} = state)
      when num_of_questions == 0 do
    {:reply, 0, state}
  end

  def handle_call(
        :get_points,
        _from,
        %{correct_answers: correct_answers, num_of_questions: num_of_questions} = state
      ) do
    {:reply, div(correct_answers * 100, num_of_questions), state}
  end

  #
  # Private
  #
  defp format_question(question) do
    answers = [question["correct_answer"] | question["incorrect_answers"]] |> Enum.shuffle()
    correct_answer_index = Enum.find_index(answers, fn x -> x == question["correct_answer"] end)
    %{question: question["question"], answers: answers, correct_answer_index: correct_answer_index}
  end
end
