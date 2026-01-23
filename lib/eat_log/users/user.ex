defmodule EatLog.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Argon2

  @derive {Inspect, except: [:pass_hash]}
  schema "users" do
    field :login, :string
    field :password, :string, virtual: true
    field :pass_hash, :string
    field :settings, :map

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:login, :password, :settings])
    |> validate_required([:login])
    |> validate_length(:password, min: 6)
    |> maybe_hash_password()
  end

  defp maybe_hash_password(changeset) do
    case get_change(changeset, :password) do
      nil ->
        changeset

      password ->
        changeset
        |> put_change(:pass_hash, Argon2.hash_pwd_salt(password))
        |> delete_change(:password)
    end
  end
end
