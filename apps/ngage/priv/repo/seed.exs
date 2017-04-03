unless (Ngage.EventDefinitionQueries.any) do
    Ngage.EventDefinitionQueries.create(Ngage.EventDefinitions.changeset(%Ngage.EventDefinitions{}, %{description: "User Registered"}))
    Ngage.EventDefinitionQueries.create(Ngage.EventDefinitions.changeset(%Ngage.EventDefinitions{}, %{description: "User Started Demo"}))
end