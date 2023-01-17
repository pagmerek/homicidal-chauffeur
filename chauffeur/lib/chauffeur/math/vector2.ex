defmodule Chauffeur.Math.Vector2 do
  import Math

  def degrees_to_radians(angle) do
    angle * (Math.pi() / 180)
  end

  def add({ax, ay}, {bx, by}), do: {ax + bx, ay + by}
  def sub({ax, ay}, {bx, by}), do: {ax - bx, ay - by}

  def rotate_car(w, angle, r) do
    angle = degrees_to_radians(angle)
    {w * sin(angle * w / r), w * cos(angle * w / r)}
  end

  def rotate_evader(angle) do
    angle = degrees_to_radians(angle)
    {w * sin(angle), w * cos(angle)}
  end
end
