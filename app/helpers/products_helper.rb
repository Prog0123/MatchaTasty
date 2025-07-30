module ProductsHelper
  def star_rating(score)
    full_stars = score.floor
    half_star = (score - full_stars) >= 0.5
    stars = "★" * full_stars
    stars += "☆" if half_star
    stars.ljust(5, "☆")
  end
end
