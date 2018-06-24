defmodule Aquiz.TriviaServer do
  use GenServer

  @difficulty "easy"
  @amount 2

  defmodule State do
    defstruct questions: [], position: 0
  end

  #
  # API
  #
  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def get_question do
    GenServer.call(__MODULE__, :get_question)
  end

  #
  # Callbacks
  #
  def init(:ok) do
    {:ok, %State{}}
  end

  def handle_call(:get_question, _from, %State{questions: questions, position: position} = state)
      when position >= length(questions) do
    result = get_new_questions()

    case result do
      {:ok, new_questions} ->
        questions = questions ++ new_questions
        question = Enum.fetch!(questions, position)
        {:reply, question, %{state | questions: questions, position: position + 1}}
      {:error} ->
        {:reply, :error, state}
    end
  end

  def handle_call(:get_question, _from, %{questions: questions, position: position} = state) do
    {:reply, Enum.fetch!(questions, position), %{state | position: position + 1}}
  end

  #
  # Private
  #
  defp get_new_questions() do
    url_for_questions =
      "https://opentdb.com/api.php?amount=#{@amount}&difficulty=#{@difficulty}&type=multiple"

    result = url_for_questions |> HTTPoison.get() |> parse_response
    # IO.inspect(result)

    case result do
      :error -> {:error}
      response -> {:ok, response["results"]}
    end
  end

  defp parse_response({:ok, %HTTPoison.Response{body: body, status_code: 200}}) do
    # A trailing bang (exclamation mark) signifies a function or macro where failure cases raise an exception.
    json = body |> JSON.decode()

    case json do
      {:ok, decoded_json} -> decoded_json
      {:error, _} -> :error
    end
  end

  defp parse_response(_) do
    :error
  end
end
