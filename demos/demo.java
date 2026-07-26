// Color-scheme demo (Java).
//
// Open this file in Neovim with this config to see the theme applied. A colored
// swatch is shown at the end of each palette line below.
//
// PALETTE (name -> hex -> where it's used):
//   white       #ffffff   background
//   black       #000000   normal text
//   deep_blue   #00008b   identifiers (variables / functions)
//   dark_green  #006400   strings
//   medium_blue #0000cd   numbers, and the git-changed gutter sign
//   purple      #800080   constants / booleans
//   green       #008000   git-added gutter sign
//   red         #af0000   git-deleted gutter sign
//   light_blue  #cce6ff   cursor line (focused)
//   light_yellow #ffe680   search highlight
//   light_gray  #e4e4e4   cursor line (unfocused)
//   faint_gray  #d0d0d0   whitespace markers (tabs / trailing spaces)
//   gray        #808080   comments (like this line)
//   orange      #ff8800   cursor in the dark popups (Telescope prompt, Claude / LazyGit)
//   float_bg  #1e1e1e   LazyGit / Telescope background
//   float_fg  #d4d4d4   LazyGit / Telescope text

class Demo {
    static String greeting = "a string literal"; // strings are dark green
    static int answer = 42;                       // numbers are medium blue
    static double pi = 3.14159;                   // floats too
    static boolean enabled = true;                // booleans / constants are purple
    static Object nothing = null;

    static String identifiersAreDeepBlue(String name, int count) {
        return name + count;
    }
}
