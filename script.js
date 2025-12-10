document.addEventListener("DOMContentLoaded", () => {
  const ctaButton = document.querySelector(".cta-shop");
  const featured = document.getElementById("featured-flowers");

  if (ctaButton && featured) {
    ctaButton.addEventListener("click", (event) => {
      event.preventDefault();
      featured.scrollIntoView({ behavior: "smooth", block: "start" });
    });
  }
});
