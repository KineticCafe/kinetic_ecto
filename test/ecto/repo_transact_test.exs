defmodule KineticEcto.RepoTransactTest do
  @moduledoc false
  use KineticEcto.SqliteCase

  # import Ecto.Query
  alias KineticEcto.RepoTransact
  alias KineticEcto.TestImage
  alias KineticEcto.TestRepo

  describe "module transact/3" do
    test "returning :ok (fn/0)" do
      assert :ok =
               RepoTransact.transact(TestRepo, fn ->
                 TestRepo.insert(%TestImage{color: "red"})
                 TestRepo.insert(%TestImage{color: "rouge"})
                 :ok
               end)

      assert TestRepo.aggregate(TestImage, :count) == 2
    end

    test "returning :ok (fn/1)" do
      assert :ok =
               RepoTransact.transact(TestRepo, fn repo ->
                 repo.insert(%TestImage{color: "red"})
                 repo.insert(%TestImage{color: "rouge"})
                 :ok
               end)

      assert TestRepo.aggregate(TestImage, :count) == 2
    end

    test "returning {:ok, value}" do
      assert {:ok, image} =
               RepoTransact.transact(TestRepo, fn repo ->
                 repo.insert(%TestImage{color: "blue"})
                 repo.insert(%TestImage{color: "bleu"})
               end)

      assert image.color == "bleu"

      assert TestRepo.aggregate(TestImage, :count) == 2
    end

    test "returning :error" do
      assert :error =
               RepoTransact.transact(TestRepo, fn repo ->
                 repo.insert(%TestImage{color: "cyan"})
                 :error
               end)

      assert TestRepo.aggregate(TestImage, :count) == 0
    end

    test "returning {:error, reason}" do
      import Ecto.Changeset

      assert {:error, %{errors: [id: {"has already been taken", _}]}} =
               RepoTransact.transact(TestRepo, fn repo ->
                 repo.insert(%TestImage{id: 1, color: "blue"})

                 %TestImage{id: 1, color: "bleu"}
                 |> change(%{})
                 |> unique_constraint(:id, name: "images_id_index")
                 |> repo.insert()
               end)

      assert TestRepo.aggregate(TestImage, :count) == 0
    end

    test "transact returning bare value: exception" do
      assert_raise CaseClauseError, fn ->
        RepoTransact.transact(TestRepo, fn repo ->
          repo.insert!(%TestImage{color: "green"})
        end)
      end

      assert TestRepo.aggregate(TestImage, :count) == 0
    end
  end

  describe "use-transact/2" do
    test "returning :ok (fn/0)" do
      assert :ok =
               TestRepo.transact(fn ->
                 TestRepo.insert(%TestImage{color: "red"})
                 TestRepo.insert(%TestImage{color: "rouge"})
                 :ok
               end)

      assert TestRepo.aggregate(TestImage, :count) == 2
    end

    test "returning :ok (fn/1)" do
      assert :ok =
               TestRepo.transact(fn repo ->
                 repo.insert(%TestImage{color: "red"})
                 repo.insert(%TestImage{color: "rouge"})
                 :ok
               end)

      assert TestRepo.aggregate(TestImage, :count) == 2
    end

    test "returning {:ok, value}" do
      assert {:ok, image} =
               TestRepo.transact(fn repo ->
                 repo.insert(%TestImage{color: "blue"})
                 repo.insert(%TestImage{color: "bleu"})
               end)

      assert image.color == "bleu"

      assert TestRepo.aggregate(TestImage, :count) == 2
    end

    test "returning :error" do
      assert :error =
               TestRepo.transact(fn repo ->
                 repo.insert(%TestImage{color: "cyan"})
                 :error
               end)

      assert TestRepo.aggregate(TestImage, :count) == 0
    end

    test "returning {:error, reason}" do
      import Ecto.Changeset

      assert {:error, %{errors: [id: {"has already been taken", _}]}} =
               TestRepo.transact(fn repo ->
                 repo.insert(%TestImage{id: 1, color: "blue"})

                 %TestImage{id: 1, color: "bleu"}
                 |> change(%{})
                 |> unique_constraint(:id, name: "images_id_index")
                 |> repo.insert()
               end)

      assert TestRepo.aggregate(TestImage, :count) == 0
    end

    test "transact returning bare value: exception" do
      assert_raise CaseClauseError, fn ->
        TestRepo.transact(fn repo ->
          repo.insert!(%TestImage{color: "green"})
        end)
      end

      assert TestRepo.aggregate(TestImage, :count) == 0
    end
  end

  describe "KineticEcto.Transact" do
    test "outputs a deprecation warning" do
      code = """
      defmodule KineticEcto.DeprecatedTestRepo do
        @moduledoc false

        use Ecto.Repo, otp_app: :kinetic_ecto, adapter: Ecto.Adapters.SQLite3
        use KineticEcto.Transact
      end
      """

      assert ExUnit.CaptureIO.capture_io(:stderr, fn ->
               assert [{KineticEcto.DeprecatedTestRepo, _}] = Code.compile_string(code)
             end) =~
               ~r/`use KineticEcto.RepoTransact`/
    end
  end
end
