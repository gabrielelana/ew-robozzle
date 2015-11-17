defmodule Robozzle.AcceptanceTest do
  use ExUnit.Case

  scenario(:incomplete) do
    """
    beb.b*
    """
    f1 []
  end

  scenario(:incomplete) do
    """
    beb.b*
    """
    f1 [:forward]
  end

  scenario(:complete) do
    """
    beb.b*
    """
    f1 [:forward, :forward]
  end

  scenario(:complete) do
    """
    b.b.b.bsb.b.b.
    b.b.b.b.b.b.b.
    b.b.b.b.b.b*b.
    """
    f1 [:forward, :forward, :left, :forward, :forward]
  end

  scenario(:out_of_stage) do
    """
    bnb*
    """
    f1 [:forward]
  end

  scenario(:stack_overflow) do
    """
    bnb*
    """
    f1 [:right, {:call, :f1}, :left]
  end

  scenario(:out_of_time) do
    """
    bnb*
    """
    f1 [:right, {:call, :f1}]
  end

  scenario(:complete) do
    """
    ..........b*b*
    ........b*b*..
    ......b*b*....
    ....b*b*......
    ..b*b*........
    beb*..........
    """
    f1 [:forward, :left, :forward, :right, {:call, :f1}]
  end
end
