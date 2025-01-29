# Code in this file is a near copy of `Repo.transact/2` in sasa1977/mix_phx_alt,
# lib/core/repo.ex:6-44 at d33a67fd6b2fa0ace5b6206487e774ef7a22ce5a. It has been modified
# to be easy to `use` without pasting in the implementation.
#
# Copyright 2022, Saša Jurić
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.
defmodule KineticEcto.Transact do
  @moduledoc """
  Add Saša Jurić's `Repo.transact/2` to your repo with `use `KineticEcto.Transact`.

  `Repo.transact/2` is a replacement for `Repo.transaction/2` with a better developer
  experience. In many cases, the use of `Repo.transact/2` can provide code that is easier
  to understand than an equivalent `Ecto.Multi` implementation. In Saša's own [words][1]:

  > I wrote `Repo.transact` after seeing a lot of production code along the lines of what's
  > written in that excellent [blog post][2] by @tomkonidas.
  >
  > The value proposition of `Repo.transact` is that control flow features such as passing
  > data around, branching, early exit, can be implemented with standard Elixir features,
  > such as variables, functions, and the `with` expression. The transactional logic is
  > less special, and it doesn't rely on some implicit behaviour of a function from some
  > library.
  >
  > Combined with the provable fact that the `transact` code is shorter (often
  > significantly), even in such simple example as in that blog post, I have no doubt that
  > the `transact` version is simpler and clearer.
  >
  > That's not to say that `Multi` is universally bad. The ability to provide each db
  > operation as data is definitely interesting, and could be useful in the cases where
  > the transactional steps need to be assembled dynamically (perhaps provided by the
  > client code). But in the vast majority of cases I've encountered, I find the multi
  > code needlessly difficult to read. This is true even in simple cases, and it becomes
  > progressively worse if the transactional logic is more involved (e.g. if it requires
  > branching early on in the transaction).
  >
  > Hence, I strongly prefer `transact`, and it's what I advise using in most situations.

  [1]: https://elixirforum.com/t/seeking-thoughts-on-advantages-of-the-repo-transact-pattern-vs-disadvantages-i-ve-read-about-ecto-multi/61733/2
  [2]: https://tomkonidas.com/repo-transact/
  """

  defmacro __using__(_) do
    quote do
      @doc """
      Runs the given function inside a transaction.

      This function is a wrapper around `Ecto.Repo.transaction`, with the following
      differences:

      - It accepts only a lambda of arity 0 or 1 (i.e. it doesn't work with `Ecto.Multi`).
      - If the lambda returns `:ok | {:ok, result}` the transaction is committed.
      - If the lambda returns `:error | {:error, reason}` the transaction is rolled back.
      - If the lambda returns any other kind of result, an exception is raised, and the
        transaction is rolled back.
      - The result of `transact` is the value returned by the lambda.

      This function accepts the same options as `Ecto.Repo.transaction/2`.
      """
      @spec transact((-> result) | (module -> result), Keyword.t()) :: result
            when result: :ok | {:ok, any} | :error | {:error, any}
      def transact(fun, opts \\ []), do: KineticEcto.Transact.transact(__MODULE__, fun, opts)
    end
  end

  @doc """
  Runs the given function inside a transaction for the provided Ecto repo.

  This function is a wrapper around `Ecto.Repo.transaction`, with the following differences:

  - It accepts only a lambda of arity 0 or 1 (i.e. it doesn't work with `Ecto.Multi`).
  - If the lambda returns `:ok | {:ok, result}` the transaction is committed.
  - If the lambda returns `:error | {:error, reason}` the transaction is rolled back.
  - If the lambda returns any other kind of result, an exception is raised, and the
    transaction is rolled back.
  - The result of `transact` is the value returned by the lambda.

  This function accepts the same options as `Ecto.Repo.transaction/2`.
  """
  @spec transact(Ecto.Repo.t(), (-> result) | (module -> result), Keyword.t()) :: result
        when result: :ok | {:ok, any} | :error | {:error, any}
  def transact(ecto_repo, fun, opts \\ []) do
    transaction_result =
      ecto_repo.transaction(
        fn repo ->
          lambda_result =
            case Function.info(fun, :arity) do
              {:arity, 0} -> fun.()
              {:arity, 1} -> fun.(repo)
            end

          case lambda_result do
            :ok -> {ecto_repo, :transact, :ok}
            :error -> ecto_repo.rollback({ecto_repo, :transact, :error})
            {:ok, result} -> result
            {:error, reason} -> ecto_repo.rollback(reason)
          end
        end,
        opts
      )

    with {outcome, {^ecto_repo, :transact, outcome}}
         when outcome in [:ok, :error] <- transaction_result,
         do: outcome
  end
end
