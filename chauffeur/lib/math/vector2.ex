defmodule Chauffeur.Math.Vector2 do
  import Math
  def degrees_to_radians(angle) do
    angle * (Math.pi / 180)
  end
end
