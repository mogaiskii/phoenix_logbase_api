defmodule Constant do
  defmacro __using__(_opts) do
    quote do
      import Constant
    end
  end

  defmacro constant(name, value) do
    quote do
      def unquote(name), do: unquote(value)
    end
  end
end
