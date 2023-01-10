defmodule Chauffeur.Math.Vector2 do
  import Math

  def degrees_to_radians(angle) do
    angle * (Math.pi() / 180)
  end

  def add({ax, ay}, {bx, by}), do: {ax + bx, ay + by}
  def sub({ax, ay}, {bx, by}), do: {ax - bx, ay - by}

  def rotate({x, y} = vector, angle) do
    angle = degrees_to_radians(angle)
    {x * cos(angle) - y * sin(angle), x * sin(angle) + y * cos(angle)}
  end
end
