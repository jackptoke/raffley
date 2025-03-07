defmodule Raffley.Repo.Migrations.AddUsernameToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :username, :string
      add :first_name, :string
      add :last_name, :string
      add :date_of_birth, :date
      add :phone_number, :string
    end

    create unique_index(:users, [:username])
  end
end
