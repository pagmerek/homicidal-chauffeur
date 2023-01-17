defmodule Chauffeur.Application do
  use Application

  def start(_type, _args) do
    # load the viewport configuration from config
    main_viewport_config = Application.get_env(:chauffeur, :viewport)

    # start the application with the viewport
    children = [
      {Scenic, [main_viewport_config]},
      Chauffeur.PubSub.Supervisor
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Chauffeur.Supervisor)
  end
end
