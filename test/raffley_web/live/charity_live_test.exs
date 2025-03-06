defmodule RaffleyWeb.CharityLiveTest do
  use RaffleyWeb.ConnCase

  import Phoenix.LiveViewTest
  import Raffley.CharitiesFixtures

  @create_attrs %{name: "some name", slug: "some slug"}
  @update_attrs %{name: "some updated name", slug: "some updated slug"}
  @invalid_attrs %{name: nil, slug: nil}

  defp create_charity(_) do
    charity = charity_fixture()
    %{charity: charity}
  end

  describe "Index" do
    setup [:create_charity]

    test "lists all charities", %{conn: conn, charity: charity} do
      {:ok, _index_live, html} = live(conn, ~p"/charities")

      assert html =~ "Listing Charities"
      assert html =~ charity.name
    end

    test "saves new charity", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/charities")

      assert index_live |> element("a", "New Charity") |> render_click() =~
               "New Charity"

      assert_patch(index_live, ~p"/charities/new")

      assert index_live
             |> form("#charity-form", charity: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#charity-form", charity: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/charities")

      html = render(index_live)
      assert html =~ "Charity created successfully"
      assert html =~ "some name"
    end

    test "updates charity in listing", %{conn: conn, charity: charity} do
      {:ok, index_live, _html} = live(conn, ~p"/charities")

      assert index_live |> element("#charities-#{charity.id} a", "Edit") |> render_click() =~
               "Edit Charity"

      assert_patch(index_live, ~p"/charities/#{charity}/edit")

      assert index_live
             |> form("#charity-form", charity: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#charity-form", charity: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/charities")

      html = render(index_live)
      assert html =~ "Charity updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes charity in listing", %{conn: conn, charity: charity} do
      {:ok, index_live, _html} = live(conn, ~p"/charities")

      assert index_live |> element("#charities-#{charity.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#charities-#{charity.id}")
    end
  end

  describe "Show" do
    setup [:create_charity]

    test "displays charity", %{conn: conn, charity: charity} do
      {:ok, _show_live, html} = live(conn, ~p"/charities/#{charity}")

      assert html =~ "Show Charity"
      assert html =~ charity.name
    end

    test "updates charity within modal", %{conn: conn, charity: charity} do
      {:ok, show_live, _html} = live(conn, ~p"/charities/#{charity}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Charity"

      assert_patch(show_live, ~p"/charities/#{charity}/show/edit")

      assert show_live
             |> form("#charity-form", charity: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#charity-form", charity: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/charities/#{charity}")

      html = render(show_live)
      assert html =~ "Charity updated successfully"
      assert html =~ "some updated name"
    end
  end
end
