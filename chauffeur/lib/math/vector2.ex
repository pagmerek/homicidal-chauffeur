defmodule Chauffeur.Math.Vector2 do
  import Math

  def degrees_to_radians(angle) do
    angle * (Math.pi() / 180)
  end

  def fmod(x, y) do
    cond do
      x <= 0 ->
        y + x

      x <= y ->
        x

      true ->
        mod = x - y
        fmod(mod, y)
    end
  end

  def add({ax, ay}, {bx, by}), do: {ax + bx, ay + by}
  def sub({ax, ay}, {bx, by}), do: {ax - bx, ay - by}

  def rotate(w, angle, r) do
    angle = degrees_to_radians(angle)
    {w * sin(angle * w/r), w * cos(angle*w/r)}
  end
end
