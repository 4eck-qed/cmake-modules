#pragma once

#include <fmt/core.h>
#include <string>

namespace color {
class Color {
public:
  inline Color() {}

  inline static Color Black() noexcept {
    Color result;
    result.mFG = black_f;
    result.mBG = black_b;

    return result;
  }

  inline static Color Red() noexcept {
    Color result;
    result.mFG = red_f;
    result.mBG = red_b;

    return result;
  }

  inline static Color Green() noexcept {
    Color result;
    result.mFG = green_f;
    result.mBG = green_b;

    return result;
  }

  inline static Color Yellow() noexcept {
    Color result;
    result.mFG = yellow_f;
    result.mBG = yellow_b;

    return result;
  }

  inline static Color Blue() noexcept {
    Color result;
    result.mFG = blue_f;
    result.mBG = blue_b;

    return result;
  }

  inline static Color Magenta() noexcept {
    Color result;
    result.mFG = magenta_f;
    result.mBG = magenta_b;

    return result;
  }

  inline static Color Cyan() noexcept {
    Color result;
    result.mFG = cyan_f;
    result.mBG = cyan_b;

    return result;
  }

  inline static Color White() noexcept {
    Color result;
    result.mFG = white_f;
    result.mBG = white_b;

    return result;
  }

  inline static Color Exit() noexcept {
    Color result;
    result.mFG = exitc;
    result.mBG = exitc;

    return result;
  }

  inline std::string FG() const noexcept { return mFG; }

  inline std::string BG() const noexcept { return mBG; }

  inline std::string Foreground() const noexcept { return FG(); }

  inline std::string Background() const noexcept { return BG(); }

  inline std::string ToString() const noexcept { return FG(); };

private:
  std::string mFG = exitc;
  std::string mBG = exitc;

  inline static std::string ToShell(int colorValue) noexcept {
    std::string s = fmt::format("\x1B[{}m", std::to_string(colorValue));

    return s;
  }

private:
  /* Colors (FG, BG)*/
  inline static const std::pair<int, int> p_black{30, 40};
  inline static const std::pair<int, int> p_red{31, 41};
  inline static const std::pair<int, int> p_green{32, 42};
  inline static const std::pair<int, int> p_yellow{33, 43};
  inline static const std::pair<int, int> p_blue{34, 44};
  inline static const std::pair<int, int> p_magenta{35, 45};
  inline static const std::pair<int, int> p_cyan{36, 46};
  inline static const std::pair<int, int> p_white{37, 47};

  /* Foreground Color strings */ // "\x1B[<Color#>mExample\033[0m"
  inline static const std::string black_f = ToShell(p_black.first);
  inline static const std::string red_f = ToShell(p_red.first);
  inline static const std::string green_f = ToShell(p_green.first);
  inline static const std::string yellow_f = ToShell(p_yellow.first);
  inline static const std::string blue_f = ToShell(p_blue.first);
  inline static const std::string magenta_f = ToShell(p_magenta.first);
  inline static const std::string cyan_f = ToShell(p_cyan.first);
  inline static const std::string white_f = ToShell(p_white.first);

  /* Background Color strings */
  inline static const std::string black_b = ToShell(p_black.second);
  inline static const std::string red_b = ToShell(p_red.second);
  inline static const std::string green_b = ToShell(p_green.second);
  inline static const std::string yellow_b = ToShell(p_yellow.second);
  inline static const std::string blue_b = ToShell(p_blue.second);
  inline static const std::string magenta_b = ToShell(p_magenta.second);
  inline static const std::string cyan_b = ToShell(p_cyan.second);
  inline static const std::string white_b = ToShell(p_white.second);

  inline static const std::string exitc = "\033[0m";
};
} // namespace color
