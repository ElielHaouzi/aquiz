defmodule Command do
  @callback display() :: {:ok, String.t}
  @callback execute() :: {:ok, term} | {:error, String.t}
end
