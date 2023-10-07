defmodule UtixTest do
  use ExUnit.Case
  doctest Utix
  import  Utix

  test "str_or_count" do
    list = :lists.seq(1, 5)
    assert "[1, 2, 3, 4, 5]" == str_or_count(list, 5)
    assert "5"               == str_or_count(list, 3)
  end
end
