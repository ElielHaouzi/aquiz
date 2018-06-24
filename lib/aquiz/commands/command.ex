defmodule Command do
  @callback display() :: {:ok, String.t}
  @callback execute() :: {:ok} | {:stop} | {:error, String.t}
end
