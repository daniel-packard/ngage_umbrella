unless (Ngage.EventDefinitionQueries.any) do
    Ngage.EventDefinitionQueries.create(Ngage.EventDefinitions.changeset(%Ngage.EventDefinitions{}, %{description: "User Registered"}))
    Ngage.EventDefinitionQueries.create(Ngage.EventDefinitions.changeset(%Ngage.EventDefinitions{}, %{description: "User Started Demo"}))
end

unless (Ngage.CustomerQueries.any) do
    Ngage.CustomerQueries.create(Ngage.Customers.changeset(%Ngage.Customers{}, %{username: "pack3754@gmail.com"}))
    Ngage.CustomerQueries.create(Ngage.Customers.changeset(%Ngage.Customers{}, %{username: "nhpackard@protolife.com"}))
end

unless (Ngage.EventQueries.any) do
    Ngage.EventQueries.create(Ngage.Events.changeset(%Ngage.Events{}, %{}))
    Ngage.EventQueries.create(Ngage.Events.changeset(%Ngage.Events{}, %{}))
end