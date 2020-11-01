defmodule RayStageWeb.AhhLiveTest do
  use RayStageWeb.ConnCase

  import Phoenix.LiveViewTest

  alias RayStage.Test

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  defp fixture(:ahh) do
    {:ok, ahh} = Test.create_ahh(@create_attrs)
    ahh
  end

  defp create_ahh(_) do
    ahh = fixture(:ahh)
    %{ahh: ahh}
  end

  describe "Index" do
    setup [:create_ahh]

    test "lists all tests", %{conn: conn, ahh: ahh} do
      {:ok, _index_live, html} = live(conn, Routes.ahh_index_path(conn, :index))

      assert html =~ "Listing Tests"
    end

    test "saves new ahh", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.ahh_index_path(conn, :index))

      assert index_live |> element("a", "New Ahh") |> render_click() =~
               "New Ahh"

      assert_patch(index_live, Routes.ahh_index_path(conn, :new))

      assert index_live
             |> form("#ahh-form", ahh: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#ahh-form", ahh: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.ahh_index_path(conn, :index))

      assert html =~ "Ahh created successfully"
    end

    test "updates ahh in listing", %{conn: conn, ahh: ahh} do
      {:ok, index_live, _html} = live(conn, Routes.ahh_index_path(conn, :index))

      assert index_live |> element("#ahh-#{ahh.id} a", "Edit") |> render_click() =~
               "Edit Ahh"

      assert_patch(index_live, Routes.ahh_index_path(conn, :edit, ahh))

      assert index_live
             |> form("#ahh-form", ahh: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#ahh-form", ahh: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.ahh_index_path(conn, :index))

      assert html =~ "Ahh updated successfully"
    end

    test "deletes ahh in listing", %{conn: conn, ahh: ahh} do
      {:ok, index_live, _html} = live(conn, Routes.ahh_index_path(conn, :index))

      assert index_live |> element("#ahh-#{ahh.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#ahh-#{ahh.id}")
    end
  end

  describe "Show" do
    setup [:create_ahh]

    test "displays ahh", %{conn: conn, ahh: ahh} do
      {:ok, _show_live, html} = live(conn, Routes.ahh_show_path(conn, :show, ahh))

      assert html =~ "Show Ahh"
    end

    test "updates ahh within modal", %{conn: conn, ahh: ahh} do
      {:ok, show_live, _html} = live(conn, Routes.ahh_show_path(conn, :show, ahh))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Ahh"

      assert_patch(show_live, Routes.ahh_show_path(conn, :edit, ahh))

      assert show_live
             |> form("#ahh-form", ahh: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#ahh-form", ahh: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.ahh_show_path(conn, :show, ahh))

      assert html =~ "Ahh updated successfully"
    end
  end
end
