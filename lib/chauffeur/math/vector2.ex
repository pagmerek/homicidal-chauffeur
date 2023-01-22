defmodule Chauffeur.Math.Vector2 do
  import Math
  def add({ax, ay}, {bx, by}), do: {ax + bx, ay + by}
  def sub({ax, ay}, {bx, by}), do: {ax - bx, ay - by}

  def atan2(y, x) do
    cond do
      x > 0 -> atan(y / x)
      y >= 0 && x < 0 -> Math.pi() / 2 - atan(y / x)
      y < 0 && x < 0 -> -Math.pi() / 2 - atan(y / x)
      x == 0 && y > 0 -> Math.pi() / 2
      x == 0 && y < 0 -> -Math.pi() / 2
      true -> 1 / 0
    end
  end
end
