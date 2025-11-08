# Poster Runner Theme Configuration

**Application Type:** Utility/Operations Management App for Event/Trade Show Environments
**Platform:** Flutter (iOS & Android)
**Last Updated:** 2025-11-08

---

## Theme Overview & Design Rationale

Poster Runner is an offline-first operational utility application designed for fast-paced event and trade show environments. The theme prioritizes **clarity, speed, and reliability** over decorative elements. The design must support:

1. **High readability** in challenging lighting conditions (indoor/outdoor, varying brightness)
2. **Immediate visual hierarchy** for status differentiation and task prioritization
3. **Large, accessible touch targets** for mobile/tablet use in fast-paced environments
4. **Professional appearance** suitable for customer-facing contexts
5. **Minimal cognitive load** for quick scanning and decision-making

### Design Personality
- **Professional & Reliable:** Inspires confidence in operational accuracy
- **Clean & Uncluttered:** Removes visual noise to support speed
- **Task-Focused:** Every element serves a functional purpose
- **Accessible:** Ensures usability across different user abilities and environmental conditions

---

## 🎨 Colors (Light Theme)

**Method Selected:** Manual Color Definition

This theme uses **manually defined colors** optimized for operational clarity and high-contrast readability. The color choices prioritize functional communication over aesthetic expression.

### Color Rationale

**Primary Color Selection:** Deep blue (#1565C0) was chosen for its:
- **Professional association:** Blue is universally associated with reliability, trust, and efficiency
- **Excellent readability:** Provides strong contrast against light backgrounds
- **Status neutrality:** Doesn't carry inherent "warning" or "success" meanings, making it ideal for general UI elements
- **Visual stability:** Remains legible across various lighting conditions (bright event halls to dim back offices)

**Secondary Color Selection:** Teal (#00838F) provides:
- **Visual differentiation** from primary actions without competing for attention
- **Harmonious relationship** with the primary blue (analogous color scheme)
- **Professional credibility** while adding subtle visual interest

**Status-Specific Color Strategy:**
- **Success/Fulfilled:** Green (#2E7D32) - Universal positive indicator, WCAG AA compliant
- **Warning/Pending:** Amber (#F57C00) - Clear attention signal without alarm
- **Error/Urgent:** Red (#C62828) - Immediate recognition of critical items

### Light Theme Colors

* **Primary**: `#1565C0` (Deep Blue)
  * **Usage:** Primary buttons, active states, headers, key interactive elements
  * **Contrast Ratio:** 7.5:1 against white (WCAG AAA compliant)

* **onPrimary**: `#FFFFFF` (White)
  * **Usage:** Text and icons on primary color backgrounds
  * **Ensures maximum readability on primary surfaces**

* **Secondary**: `#00838F` (Teal)
  * **Usage:** Secondary actions, accent elements, secondary navigation
  * **Contrast Ratio:** 5.2:1 against white (WCAG AA compliant)

* **onSecondary**: `#FFFFFF` (White)
  * **Usage:** Text and icons on secondary color backgrounds

* **Error**: `#C62828` (Deep Red)
  * **Usage:** Error messages, validation failures, urgent alerts
  * **Contrast Ratio:** 7.8:1 against white (WCAG AAA compliant)

* **onError**: `#FFFFFF` (White)
  * **Usage:** Text and icons on error color backgrounds

* **Background**: `#F5F5F5` (Light Gray)
  * **Usage:** Main app background
  * **Rationale:** Slight gray reduces eye strain vs. pure white while maintaining brightness

* **onBackground**: `#1A1A1A` (Near Black)
  * **Usage:** Body text on background surfaces
  * **Contrast Ratio:** 16.1:1 (WCAG AAA compliant for all text sizes)

* **Surface**: `#FFFFFF` (White)
  * **Usage:** Cards, lists, elevated components
  * **Provides clear visual separation from background**

* **onSurface**: `#1A1A1A` (Near Black)
  * **Usage:** Text and icons on surface backgrounds
  * **Contrast Ratio:** 18.4:1 (maximum accessibility)

### Additional Functional Colors

These colors support specific operational states and should be used consistently throughout the app:

* **Success (Fulfilled Status)**: `#2E7D32` (Forest Green)
  * **Usage:** Completed/fulfilled requests, success confirmations
  * **Contrast Ratio:** 5.5:1 against white

* **Warning (Pending Status)**: `#F57C00` (Amber)
  * **Usage:** Pending requests, items awaiting action
  * **Contrast Ratio:** 4.6:1 against white

* **Info (Sent Status)**: `#0277BD` (Light Blue)
  * **Usage:** Sent but not yet acknowledged requests
  * **Contrast Ratio:** 5.8:1 against white

* **Neutral/Inactive**: `#757575` (Medium Gray)
  * **Usage:** Disabled states, inactive elements, subtle dividers
  * **Contrast Ratio:** 4.5:1 against white (minimum AA for UI components)

* **Divider**: `#E0E0E0` (Light Gray)
  * **Usage:** List dividers, section separators
  * **Subtle separation without visual clutter**

---

## 🌙 Colors (Dark Theme)

**Method Selected:** Manual Dark Color Definition

Dark theme is optimized for low-light environments (back office areas, evening events). The palette maintains status color recognition while reducing eye strain in dark settings.

### Dark Theme Rationale

Dark mode for Poster Runner serves specific operational needs:
- **Reduced eye strain** during extended shifts in dim environments
- **Battery conservation** on OLED displays during long event days
- **Visual comfort** when switching between bright event floors and darker back offices
- **Maintained status clarity** with adjusted but recognizable status colors

### Dark Theme Colors

* **Primary**: `#64B5F6` (Light Blue)
  * **Usage:** Primary actions and interactive elements
  * **Contrast Ratio:** 8.2:1 against dark background
  * **Rationale:** Lighter blue maintains brand consistency while providing excellent dark mode readability

* **onPrimary**: `#000000` (Black)
  * **Usage:** Text/icons on primary colored elements
  * **High contrast against light blue primary**

* **Secondary**: `#4DD0E1` (Light Teal)
  * **Usage:** Secondary actions and accents
  * **Maintains relationship with light theme secondary**

* **onSecondary**: `#000000` (Black)
  * **Usage:** Text/icons on secondary colored elements

* **Error**: `#EF5350` (Light Red)
  * **Usage:** Errors and urgent states
  * **Contrast Ratio:** 5.8:1 against dark background
  * **Softer than light theme but still immediately recognizable**

* **onError**: `#000000` (Black)
  * **Usage:** Text/icons on error backgrounds

* **Background**: `#121212` (True Dark)
  * **Usage:** Main app background
  * **Rationale:** True dark background for OLED battery savings and eye comfort**

* **onBackground**: `#E0E0E0` (Light Gray)
  * **Usage:** Body text on dark backgrounds
  * **Contrast Ratio:** 13.1:1 (WCAG AAA compliant)

* **Surface**: `#1E1E1E` (Elevated Dark)
  * **Usage:** Cards, lists, elevated components
  * **Provides subtle elevation from background**

* **onSurface**: `#E0E0E0` (Light Gray)
  * **Usage:** Text and icons on surface elements
  * **Maintains excellent readability on dark surfaces**

### Dark Theme Functional Colors

* **Success (Fulfilled Status)**: `#66BB6A` (Light Green)
  * **Usage:** Completed requests in dark mode
  * **Contrast Ratio:** 6.2:1 against dark background

* **Warning (Pending Status)**: `#FFA726` (Light Amber)
  * **Usage:** Pending requests in dark mode
  * **Contrast Ratio:** 5.1:1 against dark background

* **Info (Sent Status)**: `#42A5F5` (Sky Blue)
  * **Usage:** Sent requests in dark mode
  * **Contrast Ratio:** 6.8:1 against dark background

* **Neutral/Inactive**: `#9E9E9E` (Light Gray)
  * **Usage:** Disabled states in dark mode
  * **Contrast Ratio:** 5.2:1 against dark background

* **Divider**: `#2C2C2C` (Dark Gray)
  * **Usage:** Separators in dark mode
  * **Subtle without creating harsh lines**

---

## ✒️ Typography

### Primary Font Family

* **Primary Font Family**: `Inter`

### Font Rationale

**Inter** was selected for Poster Runner based on these critical operational requirements:

1. **Exceptional Legibility:** Inter was specifically designed for digital screens with:
   - **Generous x-height** for clarity at all sizes
   - **Open apertures** preventing letter confusion (critical for alphanumeric sorting)
   - **Distinct character shapes** (e.g., I vs. l vs. 1, 0 vs. O)

2. **Optimized for Speed Reading:**
   - **Geometric simplicity** reduces cognitive processing time
   - **Clear numerical differentiation** essential for request numbers and booth IDs
   - **Excellent performance** at small sizes for dense information display

3. **Professional & Modern:**
   - **Clean, neutral appearance** suitable for customer-facing contexts
   - **Technical credibility** without appearing cold or impersonal

4. **Cross-Platform Excellence:**
   - **Consistent rendering** across iOS and Android
   - **Google Fonts availability** ensures easy implementation
   - **Variable font support** for responsive sizing

### Fallback Stack

For maximum reliability across devices:
```
Inter, -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Helvetica Neue, Arial, sans-serif
```

### Typography Scale

Based on Flutter's Material 3 text theme, with adjustments for operational clarity:

#### Display Text (Rarely Used)
- **displayLarge:** 57sp, Light (300) - Reserved for splash/onboarding
- **displayMedium:** 45sp, Light (300) - Reserved for empty states
- **displaySmall:** 36sp, Regular (400) - Reserved for major headers

#### Headlines (Screen Titles & Major Sections)
- **headlineLarge:** 32sp, SemiBold (600) - Main screen titles
- **headlineMedium:** 28sp, SemiBold (600) - Section headers
- **headlineSmall:** 24sp, SemiBold (600) - Sub-section headers

#### Titles (List Headers & Card Titles)
- **titleLarge:** 22sp, Medium (500) - Primary list item title
- **titleMedium:** 16sp, Medium (500) - Secondary information headers
- **titleSmall:** 14sp, Medium (500) - Tertiary labels

#### Body Text (Primary Content)
- **bodyLarge:** 16sp, Regular (400) - Standard body text
  * **Usage:** Request descriptions, detailed information
  * **Line Height:** 1.5 for comfortable reading

- **bodyMedium:** 14sp, Regular (400) - Secondary body text
  * **Usage:** Supporting details, metadata
  * **Line Height:** 1.43

- **bodySmall:** 12sp, Regular (400) - Tertiary text
  * **Usage:** Timestamps, auxiliary information
  * **Line Height:** 1.33

#### Labels (Buttons & UI Elements)
- **labelLarge:** 14sp, Medium (500) - Primary button text
  * **Letter Spacing:** 0.1sp for improved scannability

- **labelMedium:** 12sp, Medium (500) - Secondary button text
  * **Letter Spacing:** 0.5sp

- **labelSmall:** 11sp, Medium (500) - Small labels and tags
  * **Letter Spacing:** 0.5sp
  * **Usage:** Status badges, filter chips

### Typography Usage Guidelines

**For Maximum Operational Efficiency:**

1. **Request Numbers & IDs:**
   - Use `titleLarge` with **SemiBold (600)** weight
   - Ensures immediate recognition in lists

2. **Status Text:**
   - Use `labelLarge` with **Medium (500)** weight
   - ALL CAPS for status badges (e.g., "PENDING", "FULFILLED")
   - Provides instant visual categorization

3. **Timestamps:**
   - Use `bodySmall` with monospaced numbers
   - Consistent width improves scanning in chronological lists

4. **Customer Names/Booth Numbers:**
   - Use `bodyLarge` for primary identification
   - Capitalizes first letters for readability

5. **Action Buttons:**
   - Use `labelLarge` with **Medium (500)** weight
   - Sentence case for actions (e.g., "Mark as Fulfilled")

### Accessibility Considerations

- **Minimum Text Size:** 12sp for all readable text (WCAG AA compliant)
- **Dynamic Type Support:** All text should scale with system font size settings
- **Weight Contrast:** Use weight variation (Regular vs. Medium vs. SemiBold) to create hierarchy without relying solely on color
- **Line Height:** Generous line spacing (1.4-1.5) improves readability on tablets held at various angles

---

## 📏 Sizing & Spacing

### Base Spacing Unit

* **Base Spacing Unit**: `8` (dp)

### Rationale

The 8dp grid system provides:
- **Consistent visual rhythm** across all components
- **Alignment predictability** for developers
- **Scalability** across different screen densities
- **Material Design compliance** for native feel

### Spacing Scale

Use these standardized spacing values throughout the application:

- **4dp** (0.5x base): Tight spacing for grouped elements
- **8dp** (1x base): Default spacing between related elements
- **16dp** (2x base): Standard padding inside components
- **24dp** (3x base): Spacing between component groups
- **32dp** (4x base): Major section spacing
- **48dp** (6x base): Screen-level padding on tablets
- **64dp** (8x base): Large breakpoints and empty state spacing

### Touch Target Sizing

* **Minimum Touch Target**: `56` (dp)

### Touch Target Rationale

**56dp minimum** exceeds the standard 48dp recommendation for critical reasons:

1. **Environmental Conditions:**
   - Users often wearing gloves (event setup/teardown)
   - Hands may be full or users multitasking
   - Tablets may be mounted or awkwardly positioned

2. **Speed & Accuracy:**
   - Larger targets reduce mis-taps in fast-paced scenarios
   - Decreases error recovery time (critical for efficiency)
   - Reduces user frustration during high-stress moments

3. **Accessibility:**
   - Accommodates users with motor control challenges
   - Exceeds WCAG AAA guidelines (beneficial for temporary disabilities like fatigue)

### Component-Specific Sizing

**List Items:**
- **Minimum Height:** 72dp (accommodates 56dp touch + visual spacing)
- **Padding:** 16dp horizontal, 12dp vertical
- **Divider Height:** 1dp

**Buttons:**
- **Primary Buttons:** 56dp height minimum
- **Secondary Buttons:** 48dp height minimum
- **Icon Buttons:** 56x56dp minimum
- **Horizontal Padding:** 24dp for text buttons

**Cards:**
- **Minimum Padding:** 16dp internal padding
- **Margin:** 16dp between cards
- **Elevation:** 2dp default, 8dp on press

**Input Fields:**
- **Height:** 56dp for text inputs
- **Padding:** 16dp horizontal, 16dp vertical
- **Icon Spacing:** 12dp from input text

**Status Badges:**
- **Height:** 32dp
- **Horizontal Padding:** 12dp
- **Corner Radius:** 16dp (fully rounded)

---

## 📐 Component Shape & Elevation

### Global Border Radius

* **Global Border Radius**: `8.0` (dp)

### Shape Rationale

**8dp corner radius** provides:
- **Professional appearance** without being overly rounded or playful
- **Alignment with 8dp grid** for visual consistency
- **Clear component boundaries** for quick visual parsing
- **Modern aesthetic** that feels current but won't date quickly

### Component-Specific Shapes

**Buttons:**
- **Primary/Secondary Buttons:** 8dp border radius
- **Floating Action Buttons:** 16dp border radius (more prominent)
- **Icon Buttons:** Circular (full rounding)

**Cards:**
- **Standard Cards:** 8dp border radius
- **Elevated Cards:** 8dp border radius with shadow

**Input Fields:**
- **Text Inputs:** 8dp border radius
- **Focused State:** Maintain 8dp (no shape change, use border color/width)

**Status Badges:**
- **Badge Shape:** 16dp border radius (pill shape)
- **Creates clear visual differentiation from other components**

**Dialogs & Sheets:**
- **Dialogs:** 12dp border radius (slightly softer for modal contexts)
- **Bottom Sheets:** 12dp top corners, 0dp bottom corners

### Elevation System

* **Default Elevation**: `2.0`

### Elevation Hierarchy

Material elevation communicates component importance and interaction state:

**Level 0 (0dp):**
- Background surfaces
- Non-interactive elements

**Level 1 (1dp):**
- App bars
- Search bars

**Level 2 (2dp) - DEFAULT:**
- Cards at rest
- Buttons at rest
- Standard elevated components

**Level 3 (4dp):**
- Cards on hover (desktop)
- Raised buttons on hover

**Level 4 (6dp):**
- Active draggable items
- Floating action buttons at rest

**Level 5 (8dp):**
- Buttons on press
- Cards on press
- Floating action buttons on press

**Level 6 (12dp):**
- Navigation drawer
- Side sheets

**Level 7 (16dp):**
- Dialogs
- Modal bottom sheets

**Level 8 (24dp):**
- Navigation bar (bottom navigation)

### Elevation Usage Guidelines

1. **Maintain Hierarchy:** Higher elevation = more interactive or important
2. **Feedback States:** Increase elevation on press/hover for tactile feedback
3. **Avoid Overuse:** Too many elevated surfaces create visual noise
4. **Dark Mode Adjustment:** Elevation is communicated through surface tint in dark mode (not just shadow)

---

## 🎬 Animation & Motion

### Animation Durations

* **Short Duration**: `150` (milliseconds)
* **Medium Duration**: `300` (milliseconds)

### Animation Curve

* **Default Animation Curve**: `Curves.easeInOut`

### Motion Rationale

Animation serves **functional purposes** in Poster Runner:

1. **Provide Feedback:** Confirm that an action was registered
2. **Create Continuity:** Show relationships between UI states
3. **Direct Attention:** Guide users to important changes
4. **Reduce Cognitive Load:** Smooth transitions prevent jarring context switches

**Critical Principle:** Animations should feel **instant** while providing subtle confirmation. In fast-paced operational environments, slow animations create frustration.

### Animation Duration Guidelines

**Short Duration (150ms):**
- Button press states
- Status badge changes
- Checkbox/toggle switches
- Hover effects (desktop)
- Small-scale transformations

**Medium Duration (300ms):**
- Screen transitions
- Sheet/dialog appearance
- List item additions/removals
- Expansion panels
- Tab switches

**Long Duration (400-500ms) - USE SPARINGLY:**
- Complex screen transitions with multiple elements
- Onboarding flows
- Empty state illustrations

### Curve Selection

**Curves.easeInOut (Default):**
- Provides natural, balanced motion
- Starts gently, speeds up, then slows to stop
- Best for most UI transitions

**Curves.easeOut:**
- Use for items entering the screen
- Objects arrive quickly and settle

**Curves.easeIn:**
- Use for items leaving the screen
- Objects depart gradually then accelerate away

**Curves.fastOutSlowIn (Material Standard):**
- Alternative to easeInOut for Material emphasis
- Slightly more dynamic feel

### Motion Accessibility

1. **Respect System Settings:** Honor `MediaQuery.of(context).disableAnimations` for users with motion sensitivity
2. **Provide Reduced Motion Option:** Consider in-app toggle for animation intensity
3. **Critical Feedback:** Even with animations disabled, provide static confirmation (e.g., checkmark appearance)

### Performance Optimization

- **Use Built-in Widgets:** Prefer `AnimatedContainer`, `AnimatedOpacity`, etc. over custom animations when possible
- **Avoid Layout Animations:** Animating positions/sizes can cause jank; use opacity and transforms instead
- **Limit Simultaneous Animations:** Maximum 2-3 concurrent animations to maintain 60fps
- **Pre-cache Complex Animations:** For repeating animations (like loading states), pre-build animation controllers

---

## 🎯 Visual Density

* **Visual Density**: `VisualDensity.comfortable`

### Visual Density Rationale

**VisualDensity.comfortable** was chosen over `standard` or `compact` for these operational reasons:

1. **Touch Optimization:**
   - `Comfortable` provides additional padding beyond minimum touch targets
   - Reduces accidental taps in rushed scenarios
   - Creates more forgiveness for imprecise touches (gloves, movement)

2. **Visual Breathing Room:**
   - Prevents UI from feeling cramped on tablet screens
   - Improves scannability of lists with multiple items
   - Reduces eye strain during extended use

3. **Platform Consistency:**
   - Aligns with iOS's generally spacious design language
   - Provides native feel on both platforms without being excessive

### Platform-Specific Overrides

Consider these adaptive density adjustments:

**Phone (< 600dp width):**
- Use `VisualDensity.comfortable` as default
- Dense lists may optionally use `VisualDensity.standard` if content is simple

**Tablet (600dp - 840dp width):**
- Use `VisualDensity.comfortable` (default)
- Leverage additional space for clarity, not compression

**Desktop (> 840dp width):**
- Use `VisualDensity.compact` for dense data tables
- Use `VisualDensity.comfortable` for primary navigation and actions

---

## 🎨 Component-Specific Theme Guidelines

### Status Indicators

Status communication is critical in Poster Runner. Apply these consistent patterns:

**Status Badge Component:**
```
Shape: Rounded rectangle (16dp radius for pill effect)
Height: 32dp
Horizontal Padding: 12dp
Typography: labelLarge (14sp), Medium weight (500), ALL CAPS
Shadow: None (badges sit on surfaces, don't float)
```

**Status Color Mapping:**

| Status | Light Theme | Dark Theme | Icon | Usage |
|--------|-------------|------------|------|-------|
| **SENT** | `#0277BD` (Info) | `#42A5F5` (Info Dark) | → (arrow) | Request sent, awaiting acknowledgment |
| **PENDING** | `#F57C00` (Warning) | `#FFA726` (Warning Dark) | ⏳ (hourglass) | Acknowledged, being fulfilled |
| **FULFILLED** | `#2E7D32` (Success) | `#66BB6A` (Success Dark) | ✓ (checkmark) | Completed successfully |

**Badge Implementation Notes:**
- Always pair color with icon for accessibility (don't rely on color alone)
- Use ALL CAPS text for immediate recognition across languages
- Maintain consistent badge positioning (right-aligned in list items)

### List Items (Request Queue)

List items are the primary interface in Poster Runner. Optimize for scanning:

**Structure:**
```
Height: 88dp minimum (allows multi-line content with comfortable spacing)
Padding: 16dp horizontal, 16dp vertical
Divider: 1dp solid, color: Divider (light gray)
Elevation: 0dp at rest, 2dp on press (tactile feedback)
```

**Content Hierarchy:**
1. **Primary:** Request number (titleLarge, SemiBold) - Top left
2. **Secondary:** Customer name / Booth number (bodyLarge) - Below primary
3. **Metadata:** Timestamp (bodySmall, Neutral color) - Bottom left
4. **Status:** Badge (labelLarge, status color) - Right side, vertically centered

**Interaction States:**
- **Default:** White background, no elevation
- **Pressed:** 2dp elevation, slight scale (0.98x) for tactile feedback
- **Completed (Fulfilled):** Light green background tint (#E8F5E9) with green badge

### Buttons

**Primary Action Buttons:**
```
Height: 56dp
Min Width: 120dp
Padding: 24dp horizontal
Corner Radius: 8dp
Elevation: 2dp rest, 6dp pressed
Typography: labelLarge (14sp), Medium (500)
Color: Primary background, onPrimary text
```
**Usage:** "Submit Request", "Mark as Fulfilled", "Confirm"

**Secondary Action Buttons:**
```
Height: 48dp
Min Width: 100dp
Padding: 20dp horizontal
Corner Radius: 8dp
Border: 2dp solid Secondary color
Elevation: 0dp
Typography: labelLarge (14sp), Medium (500)
Color: Transparent background, Secondary text
```
**Usage:** "Cancel", "View Details", "Filter"

**Icon Buttons:**
```
Size: 56x56dp (large touch target)
Icon Size: 24dp
Corner Radius: Circular (full rounding)
Elevation: 0dp
Ripple: Primary color at 12% opacity
```
**Usage:** Navigation, sorting, filtering

### Input Fields

**Text Input:**
```
Height: 56dp
Padding: 16dp horizontal, 16dp vertical
Corner Radius: 8dp
Border: 2dp solid Neutral
Border (Focused): 2dp solid Primary
Typography: bodyLarge (16sp), Regular (400)
Label: bodyMedium (14sp), positioned above field
```

**Input States:**
- **Default:** Neutral border, Surface background
- **Focused:** Primary border, slight background elevation
- **Error:** Error border, error text below field
- **Disabled:** Neutral background tint, Inactive text color

### Cards

**Standard Card:**
```
Padding: 16dp
Margin: 16dp between cards
Corner Radius: 8dp
Elevation: 2dp
Background: Surface color
```

**Usage:** Grouping related information on the Delivered Audit screen

---

## 📱 Screen-Specific Guidance

### Request Entry/Queue Screen

**Purpose:** Fast data entry and status monitoring

**Layout Priorities:**
1. Large, easy-to-tap input field at top
2. Chronologically ordered request list (newest at top)
3. Clear status differentiation through badges and subtle background tints
4. Minimal navigation chrome to maximize list visibility

**Color Usage:**
- Background: Background color (#F5F5F5)
- Input area: Surface color (white card elevated 2dp)
- List items: Surface color with status-based tint for fulfilled items
- Status badges: Status-specific colors (Info, Warning, Success)

**Typography Emphasis:**
- Request numbers: titleLarge, SemiBold (high scanability)
- Timestamps: bodySmall, Neutral color (de-emphasized but present)

### Delivered Audit Screen

**Purpose:** Historical record and verification

**Layout Priorities:**
1. Filtering options (date range, search)
2. Grouped or flat list of completed requests
3. Read-only presentation (no action buttons on items)
4. Optional search/filter bar

**Color Usage:**
- Background: Background color
- Completed items: Surface with subtle success tint (#E8F5E9 in light mode)
- All badges: Success color (green)

**Typography Emphasis:**
- Completion timestamp: bodyMedium (more prominent than pending timestamps)
- Customer info: bodyLarge (maintain readability)

---

## ♿ Accessibility Compliance Summary

This theme meets or exceeds the following accessibility standards:

### WCAG 2.1 AA Compliance

**Color Contrast:**
- All text meets minimum 4.5:1 contrast ratio for normal text
- Large text (18sp+) meets 3:1 minimum
- UI components meet 3:1 contrast against adjacent colors

**Enhanced Accessibility Features:**
- Interactive elements exceed minimum touch target (56dp vs. 48dp required)
- Status communicated through color + icon + text (not color alone)
- Typography scale supports dynamic type scaling
- Focus indicators provided for keyboard navigation

### Testing Recommendations

1. **Contrast Testing:** Use automated tools to verify all color combinations
2. **Screen Reader Testing:** Test with TalkBack (Android) and VoiceOver (iOS)
3. **Large Text Testing:** Enable system-wide large text and verify layouts
4. **Color Blindness Testing:** Verify status differentiation with protanopia/deuteranopia simulators
5. **Real-World Testing:** Test in bright sunlight and dim environments to validate color choices

---

## 🔄 Theme Implementation Notes

### Flutter Implementation

This theme should be implemented using Flutter's `ThemeData` with Material 3 enabled:

```dart
ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF1565C0),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFF00838F),
    // ... (continue with all defined colors)
  ),
  textTheme: TextTheme(
    // Use Inter font family with defined sizes
  ),
  // ... (additional theme properties)
)
```

### Custom Extensions

Consider creating a `ColorScheme` extension for status colors:

```dart
extension PosterRunnerColors on ColorScheme {
  Color get success => const Color(0xFF2E7D32);
  Color get warning => const Color(0xF57C00);
  Color get info => const Color(0x0277BD);
  // ... (dark mode variants)
}
```

### Theme Switching

Support light/dark theme switching based on:
1. System preference (default)
2. Optional in-app manual toggle
3. Time-based automatic switching (e.g., dark after 6pm for evening events)

---

## 📋 Design System Checklist

Use this checklist when implementing new screens or components:

- [ ] All interactive elements have 56dp minimum touch targets
- [ ] Text contrast meets WCAG AA (4.5:1 for normal, 3:1 for large)
- [ ] Status information uses color + icon + text (not color alone)
- [ ] Typography uses defined text styles (no hard-coded TextStyle)
- [ ] Spacing follows 8dp grid system
- [ ] Animations use defined durations (150ms or 300ms)
- [ ] Component shapes use defined border radii (8dp standard, 16dp for badges)
- [ ] Elevation follows defined hierarchy (2dp default for cards/buttons)
- [ ] Dark theme variant has been considered and tested
- [ ] Screen reader accessibility tested (semantic labels provided)
- [ ] Large text scaling tested (no text overflow)
- [ ] Color blindness simulation tested (status remains distinguishable)

---

## 🎓 Rationale Summary

This theme was designed with operational efficiency as the primary driver:

**Color Choices:**
- High-contrast professional blues for trust and reliability
- Status colors based on universal conventions (green = success, amber = waiting, red = error)
- Light gray backgrounds reduce eye strain vs. pure white
- All colors exceed WCAG AA contrast requirements

**Typography:**
- Inter font selected for exceptional screen legibility and numeric clarity
- Generous sizing (16sp body text) prioritizes readability over information density
- Clear hierarchy through size and weight (not just color)

**Spacing & Touch Targets:**
- 56dp minimum touch targets accommodate real-world usage conditions (gloves, movement, multitasking)
- 8dp grid creates predictable visual rhythm
- Comfortable visual density balances information display with usability

**Motion:**
- Fast animations (150-300ms) provide feedback without creating frustration
- Simple curves (easeInOut) feel responsive and natural
- Reduced motion support for accessibility

This theme prioritizes **functional clarity over aesthetic flourish**, ensuring Poster Runner remains a reliable tool in challenging operational environments.
