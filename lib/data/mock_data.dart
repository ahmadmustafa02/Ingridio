import 'package:ingridio/models/ingredient.dart';
import 'package:ingridio/models/recipe.dart';
import 'package:ingridio/models/recipe_cooking_step.dart';
import 'package:ingridio/models/recipe_ingredient_line.dart';

class MockData {
  MockData._();

  static const String pantryProfileAvatarUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDpZlDQ4fI8denI-mTmfJtzbNDEN4vL0sZFjbhIxjNchJ0lKLmL8ZAbSfYnZhfsLxuoiGAnHthy2SaA4ZQs0UPSV38T7bOZ4k4IVsICo99wZ95p-nZ3NkDGyP8tPyPeHYFEUvgmfR5VBlBbflA-OEMb_kUl3bQNwDlPyl7lHyQZqLTZ4hnljjLm8V6LT5stjqU_fnY4OY1ghAjJO5xpf0tXhPk8wkk8GMcjm6io78RFhBH5iT7uraDVGXqtzWdPziZVd5UBMejMbcs';

  static const String profileHeaderAvatarUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBys63w1kcA55IoHE_z6s-3ExjlKv2qRxzzbmJdVmaqXo7Du8RVRJJLwV_mEendONL81xoKWubC8PWJVNsgnXmJ5WAsf66S9_ES_Isz2aouHCUDW0KpUCMyoM9FxluL0jKGpYMudKfrZOlJ-ivxinDlAQJWXrAv2pUUFGrwFrwFz-zWLwwpE07VULL_gwhDfw4aofMsw9SnBSHw1_QzuYJLBb33aSJ9L6Sz5fJpDox-5a1ZPi2Q9xmAsdTyegKHwKRiT0t8mEprPVo';

  static const String profileHeroAvatarUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDjK50i8UFisvXBDXX71AtZ5hwq-XIOWp6xjTUNaY_Elaq0FVYfoCmCAxDfRbe7yhKdx_39UO8gLiOLr8t0kgOqeFCpKzvlcH99cnwgSCZRYdjus966iyu2ReyNa3cYOGgtiVuX0sGxBZwGrXiLSk_t_J2J5av29F8onALtw__Llk21Tkxpcl8hUxJ175EKeyIISB-k29JQi2cnMufagN0vJkMFBAjBM_BrJaLTRrOU6GxxuYVOPVyi-TiLDSHi9oe8cztvAAj9xLI';

  static const String pantryProduceDecorationUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuA9LcyeS3TmxRfyFJKK-cv1Fs3649yHJ231KxxRWKX1YVzpcE5UG9h2Cd_uyo-Uh3lXh2-3qi5NpFsxg0PNTcOn5sjBsUe7l_whB8k1rpWNx5TARlaBWocdl6qSVtLtozUK_zzbDfXbxRyq1coxHP3RjKVXzINNy0BzF5jemH1hYIOdsoNoPJYDfJdfZwnpHUIziPb3rMoXBuQ5GrXY0hK7H7TWGT5mJ9mFiL4MvEymGlF-7bb6BaJFYmL60_LoH_SAuJlg7pNHS_s';

  static const String pantryDairyDecorationUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBB9H8iuBnhRf_rA_Nk-uMPB_nNEthu3R8HoqjtYjXaaLNbatmzXMVhyhZiSn6MMAHTLeBiW3YkCmmRArvxedtn7sKlFvquRrs9x7fm3uKCntYmAlowIrg6Uppo9Ixl2TIdGvewQfpJgkleH18K2gZcmPktUPSz-B5GYRo3Hs0DYFbIaHYpjvfbv86dVjEcWFh14vCd2qkqfK15d8bh-qHhqORO10ZYLu8v9_ybqfIKelPNH2F3xkfpH3oxCJo9GVZf3ZUqhXZUfZw';

  static const List<Ingredient> mockPantry = <Ingredient>[
    Ingredient(
      id: 'tomatoes',
      name: 'Tomatoes',
      category: 'Fresh Produce',
      quantity: 4,
      unit: 'pcs',
      daysLeft: 3,
      source: IngredientSource.camera,
    ),
    Ingredient(
      id: 'spinach',
      name: 'Spinach',
      category: 'Fresh Produce',
      quantity: 1,
      unit: 'bunch',
      daysLeft: 1,
      source: IngredientSource.camera,
    ),
    Ingredient(
      id: 'avocado',
      name: 'Avocado',
      category: 'Fresh Produce',
      quantity: 2,
      unit: 'pcs',
      daysLeft: 5,
      source: IngredientSource.manual,
    ),
    Ingredient(
      id: 'carrots',
      name: 'Carrots',
      category: 'Fresh Produce',
      quantity: 5,
      unit: 'pcs',
      daysLeft: 7,
      source: IngredientSource.camera,
    ),
    Ingredient(
      id: 'smoked_paprika',
      name: 'Smoked Paprika',
      category: 'Spices',
      quantity: 1,
      unit: 'jar',
      stockLevel: 'High',
      source: IngredientSource.manual,
    ),
    Ingredient(
      id: 'cumin_seeds',
      name: 'Cumin Seeds',
      category: 'Spices',
      quantity: 1,
      unit: 'jar',
      stockLevel: 'Med',
      source: IngredientSource.manual,
    ),
    Ingredient(
      id: 'turmeric',
      name: 'Turmeric',
      category: 'Spices',
      quantity: 1,
      unit: 'jar',
      stockLevel: 'High',
      source: IngredientSource.manual,
    ),
    Ingredient(
      id: 'star_anise',
      name: 'Star Anise',
      category: 'Spices',
      quantity: 1,
      unit: 'jar',
      stockLevel: 'Low',
      source: IngredientSource.manual,
    ),
    Ingredient(
      id: 'basmati_rice',
      name: 'Basmati Rice',
      category: 'Grains',
      quantity: 2,
      unit: 'kg',
      source: IngredientSource.manual,
    ),
    Ingredient(
      id: 'quinoa',
      name: 'Quinoa',
      category: 'Grains',
      quantity: 500,
      unit: 'g',
      source: IngredientSource.manual,
    ),
    Ingredient(
      id: 'red_lentils',
      name: 'Red Lentils',
      category: 'Grains',
      quantity: 1,
      unit: 'kg',
      source: IngredientSource.manual,
    ),
    Ingredient(
      id: 'spaghetti',
      name: 'Spaghetti',
      category: 'Grains',
      quantity: 500,
      unit: 'g',
      source: IngredientSource.manual,
    ),
    Ingredient(
      id: 'flour',
      name: 'All Purpose Flour',
      category: 'Grains',
      quantity: 2,
      unit: 'kg',
      source: IngredientSource.manual,
    ),
    Ingredient(
      id: 'eggs',
      name: 'Organic Eggs',
      category: 'Dairy & Proteins',
      quantity: 6,
      unit: 'pcs',
      source: IngredientSource.camera,
    ),
    Ingredient(
      id: 'yogurt',
      name: 'Greek Yogurt',
      category: 'Dairy & Proteins',
      quantity: 1,
      unit: 'pack',
      source: IngredientSource.camera,
    ),
  ];

  static const String profileAvatarUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDyqfwFbNBNN1b60FqZRRegUm01Lln_o7krvV3aoshmw1T_I9NrnUOU2B53G26V2iTZ21TInBbhVzm6PoC72jqEY7i3SKdhLzd8v3Zg3WLrvp3TRaJ7RBRGwgzOCkjLTpHjDZGvW-feXRXZtaFv7syYsmNGQ7NOSx8HOz3id3x55VtGur1x3rwlEahuROo-mTkGp_L7v9TPmVem0AHamOYRDUkIkrBVFGl_b0_1sPN9m1LeOoOKb3vjqxfO7pUAuFBCEM2JcDKAt6Y';

  static const String heroImageUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBcz_AB8U5GBubC_EnDBPMIF-Jz8Yn9nFf3o3DOKiOfH3QrCRG3GH7a5DhlqUHP0ypBtBBMT9QBPPLmagfO_15GgiAOxKvu9eoX6uQW7eSt3dOJvvsKJidFhXqyqONCSTX1g-2TZExOXmiOlSYEg71HgXu46_9oLxw35rSkXIxUWpOjlPzh-1V6u23i336lzvdbCq5k4yQ0By_yS_SrOXwMjgY7D7t2zQRM5M2BnxIZOVETY-IVlacnkgGo9q8uzuxyK6qo5O3o_tA';

  static const String recipeMatchHeroImageUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuAxd4HxbBA9Baq03Kyff622LDbVjbCSddczg-WfZNRLYhErGSfhGO3h1QLdHsIp0zHgbYcacmGFS6tvf19fMKr8DtBkKCYeAPniBXoGQUu8lCfhw3DWqnERyE8R_3qSaD2IjfWoM7aZVR3nNHIbLCwL-NNK3meV4MAzld6PHvFphkAn7oEeuNN30Ha_415okTwuSXYVATJbKNu0bAAVuu_KB4Rc4Zras-O1Zzg6JnEjJBRyvzr0sRJfKJjzQI0h3Cc8ahUkZiUuS0g';

  static const String heroEyebrow = 'Recommended for you';
  static const String heroTitle = 'Savor the spices of Karachi.';
  static const String heroSubtitle =
      'Your pantry is 85% ready for an authentic Biryani tonight.';

  static const List<String> homeDietChipLabels = <String>[
    'Pakistani Cuisine',
    'Halal',
    'High Protein',
    'Quick Prep',
  ];

  static const String discoveryProfileAvatarUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuCa0WAXMzHQKfVwiJLjb6fwNRsuPrTXe6poxA_bZu7t23hei59sYx4dsz2RaMyh0_u_APYzJobSNX0ESWjqR13jJuhMfX5lif5S_81r6phkr7ikEpwuRywQ-7Ar22hqo2XF1M-n0ZToMIJ05potLKDfzMjnOxHVaxbV3-tobnherIaPyR517e2Nqc1gL7prRHhQ8yxC1RrtEXb8U8yPjZa2zhufiRlMCtPPSZnBuHyDkhLUomj-uFhBcKygVSxjph_5krA837qB6ec';

  static const String cuisineCirclePakistaniUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuAog7CMRtL6TvC4jiPPmqr-qu0-CFAUYWZmS8a-_nA2xKjqvw_HYOk_aCPoGP-QOIeyKSo3yMH48XaNbaKiLgVBF0E25veWIXA7Am_1BMKa5F04pWv6ACaYSRlbSecNcheL4TByk-ruRIh3uolZaODlbjV5nv3vjXwjfUNaLGoLwcgHjcF_5CmkL64ebiPGujZgtKI1_qxRKopdW66diuZ4CuPydFNzDmQBpRGfOkW_5jakD3LzaEXbTCvNsxJiBtjqw0EModiZF50';

  static const String cuisineCircleItalianUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuCBwsq7WpUoRMZzFUAyqSt4Bals2GFg_VbSu5LqzUtQ8wDElAGzCgJqpbPFr_W6ib-YvRozhwdkCcGdv2Lwq5qDi7r6jH0_uWp93mlBq3eDhc0GTMJmPulwLOQ3-Yy72uRzjmpVayMRkqphoTXKlOuhYVQOE6ZaboHrcajxJB4A1T8SGk7H08zzE33KtP439IFyHGUQNpN7G4u6TYtHBLeNA7qEgAP5ilpIpLYxAO60kGcLXOZCq9uwS9RmCivMqou4aE82FkDN6r8';

  static const String cuisineCircleJapaneseUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuB55gVXUdatkBEpVHm20soWPr1regxOiZUbK_YaVnxTDLBMQ4LlQs-fl02gWTEE6SFpPd8wFhf8YbvIqmLnoMwjBHaVT-Gpboawy29lHHezpUucRr6PArwaO-EGmtU4N4YkuGZM_-YzETEFH1ErW1zSEX4RPb2Iwk4lWL-8_CcuiMOWdEdDslABszrEJ-uYOTZKdTOuTjJRX8ob2AT4H6aln_ABE8WdSkMkHQw9r0BfE835VHzZ0i88mbmWulmOmjlzvLRaUhD3iYY';

  static const String cuisineCircleMexicanUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuC_TIZ5Niy94i0fc0NsSq7u7_PzFF2hHiP67qag0IHVzFhnqKx6MyaZ3EaCnASn0aEJP9amh8ATuPrlwyqJCz4LRY8jRXhYQNKISLfJBkbyDXWt9vScA072-NiOrbBStoySrWvbqHXfKqzKwbGpCy9UCQ_bNMFJIFbmDMtB_l1GU6eEVM8SwIl1v5uaDKpQfA2W-jnU8VW3X3-13gSNhlYwj7F4EqNVHwt4TlXAeli1Fje0hA8aZ1L6fbwLhLjErwqqJ37XRbncavA';

  static const List<Recipe> mockRecipes = <Recipe>[
    Recipe(
      id: '1',
      name: 'Vibrant Zesty Harvest Bowl',
      cuisine: 'Healthy',
      cookTime: '20 mins',
      difficulty: 'Easy',
      calories: 380,
      tag: 'AI Top Pick',
      description:
          'Colorful bowl with fresh greens, roasted chickpeas, and zesty dressing.',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDkLubCmiShfbWLEiDL922JJlaadL9XJcx-aRcsQWRucEvePYvcww5SfV1lJ-ZL1WMVtou2vJSin2W0w8FlgAe4Xc_bguhaUtEj7FY-nk3To5hW7LoJcQwTC85vRNxDe1HVgNXN4hCcizb0mRtF3_-rpoZ6BE6mHiv0Bexd2jxcxrZ9X5iC2fHp93QeVB_F9ePkDmwcWoBVE8fb7qk9bEWRGldaOwzC7VChSGs3UBQAQvF4U4fZkKQdpl2B3-L-ajKUryWxVpVQgl0',
      cardSubtitle: 'Ready in 20 mins • Healthy Choice',
      searchKeywords: <String>['bowl', 'avocado', 'chickpeas', 'kale', 'buddha'],
      ingredients: const <String>[],
      steps: const <String>[],
    ),
    Recipe(
      id: '2',
      name: 'Classic Greek Salad',
      cuisine: 'Mediterranean',
      cookTime: '10 mins',
      difficulty: 'Easy',
      calories: 220,
      tag: '',
      description: 'Olives, feta, and crisp vegetables with olive oil.',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuB987vgoLrCvkIeqXUhwjqQovW76SroqevfrS5iSFtyAG4DOa9egIXVYaa1xam_8RfPeYvJNqYgBT3_F8C9fL5vRWwQa9SAwXZUNpzz0nLYlUNMNDkxUT-vUld-J-tDOMhnwEekLB8lM-nnK5ANaTuunhX6AhCK9Vg1tAKppGpUw2pI_kQmE7zqax_HWv5ILWVqSLCbXr4De2_jwlwtpdWvx5W2jyujnzdXcceE4g1fIQTSsVqhTavMKTL_k2T272DBk3V8ryAFuNc',
      searchKeywords: <String>['greek', 'salad', 'feta', 'olives'],
      ingredients: const <String>[],
      steps: const <String>[],
    ),
    Recipe(
      id: '3',
      name: 'Summer Berry Bowl',
      cuisine: 'Healthy',
      cookTime: '15 mins',
      difficulty: 'Easy',
      calories: 290,
      tag: '',
      description: 'Smoothie bowl topped with berries, flowers, and almond flakes.',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCIyXQu2R9LfMwLqkFhc42DW-hQsA0kvABJfSmPcTkpOyTGWk3e1Ud0031eYLBUsvHO2zU84cfpXB5DNUH8w0bs4MmaAphR4nDQXyNP-L7Cyxq_lh-SCUGYPe3MMui3FrmfDeEiGoCTIBQiFZaTMlKSghT0osEbrNN6c4TZZpnKhhC8f5quOBh8obUPb9MetCE6f6KC_H59JMwOnSCBF2YcykwqToj61JM3IWaYO0A6yfA_Ij8H3xSBE9zX2ExYfe23MR8OJo30FU0',
      searchKeywords: <String>['berry', 'smoothie', 'breakfast', 'almond'],
      ingredients: const <String>[],
      steps: const <String>[],
    ),
    Recipe(
      id: '4',
      name: 'Lemon Herb Grilled Salmon',
      cuisine: 'Healthy',
      cookTime: '15 mins',
      difficulty: 'Medium',
      calories: 320,
      tag: 'Low Carb',
      description:
          'Fresh Atlantic salmon marinated with organic dill, lemon zest, and cracked black pepper. Perfect for a light dinner.',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCavVZfNy_GqYLQA9fvRxZ17JeWm_Sk5JNZqGxu2YwZRlLUGk4-nLwUNcbzlXW2VZOOs8VSoAkIhRijxHco91vzf6eveq3Ti6LmtrXMmwWCegLPHP6_7z27vncft1su60K2OldC-P52cMQNXVxj0fO_5tCYbc-Hx8WNzC9aZVX6qDQjDefztSQRJ34XVvBNowQs-Af40VmVBokm4lH--QFhhDWQ9vyJMzejAYAkLBxXbH6amAqZlsEnDEeB-Be6sT5gnd09TTl20V0',
      searchKeywords: <String>['salmon', 'fish', 'grill', 'lemon', 'protein'],
      ingredients: const <String>[],
      steps: const <String>[],
    ),
    Recipe(
      id: '5',
      name: 'Roasted Sweet Potato Quinoa',
      cuisine: 'Healthy',
      cookTime: '25 mins',
      difficulty: 'Easy',
      calories: 410,
      tag: 'High Protein',
      description:
          'A nutrient-dense bowl featuring roasted yam, fluffy tri-color quinoa, and a maple-tahini drizzle.',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBREcZu--wWsMHyF6H1MzLhkf8TVqO5eZZ1oDwFGNyX2OlPgWDNw83vB2LifHjq-f7gPcAtNdXQ5QiXlZYycU21EtN_J0GvbOXCnIY_epXQ9Vffpz8rVXa892Fwhd5AnyjgUX5gLv3pPrDlKC82LjVueELxho0a3Y9BeyxB1c23PaIsHkJmnP2XDBzPYeWBKap2ATLxTkqp2a_Zjgy1PqUFF0Gl0nx4kco6wPl3A6CpmxxMcr6sK8eGeheVZFgKu9yOGb-_YhWqCEc',
      searchKeywords: <String>['quinoa', 'sweet potato', 'vegan', 'bowl'],
      ingredients: const <String>[],
      steps: const <String>[],
    ),
    Recipe(
      id: '6',
      name: 'Chana Chaat Bowl',
      cuisine: 'Pakistani',
      cookTime: '20 mins',
      difficulty: 'Easy',
      calories: 350,
      tag: 'AI Smart Pick',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBpoA6HqWr9P2gsmarOJHal8gK5Dw9BRrsxf1ZewYZUmC-cfXMPSECOHUUqyT4EwC-YB33ClHgpDdR6grsP6Hy6H0AU50rvbgfctopgdAroyClyK8QfFUWoWCkzl40UjWzdHqGmjp8vufy6Qol1pM9YIOZQJaOUOm_LD8_qR_XO3Jmjpl2NCNuX6fGnltiO9obajbwmYvMQOqU2dIq_XxFsHGMJFaU7r5hq9AD3IR1Ahk3_Um7-ceDZZ0L1Kx3RpXNChwN0kc6WY20',
      cardSubtitle: 'Perfect for your fiber goals',
      showAiBadge: true,
      description: 'Chickpea chaat with chutneys and fresh herbs.',
      searchKeywords: <String>['chaat', 'chickpeas', 'pakistani', 'street food'],
      ingredients: const <String>[],
      steps: const <String>[],
    ),
    Recipe(
      id: '7',
      name: 'Seekh Kebabs',
      cuisine: 'Pakistani',
      cookTime: '25 mins',
      difficulty: 'Medium',
      calories: 420,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAjOGKcLnqwbkCld-PtTZjpUjvnb0Cyuph5JlSZXwzlpddVRNIaa6HY6HXX_P3SOEKJDqfzOIHfuNnalF9AaIlYU6bj-v1q7TKPWBnhIH2n4Ehj-aCZ84UJABcO29UYBYCLm9MGmPjZa0u1X525wNGRtVG4vXFV7lfoJ6AHYb-4IYj-gPSkuwmVvhB6XWTe1NegjCfoyy1aOmwGAz61I2pFVXgpL1aXSGKiYaYCdOEMrR2YROh2GaUYSR32oS-SdjY8PBz8XyRr850',
      description: 'Spiced minced meat skewers with mint chutney.',
      searchKeywords: <String>['kebab', 'meat', 'grill', 'pakistani'],
      ingredients: const <String>[],
      steps: const <String>[],
    ),
    Recipe(
      id: '8',
      name: 'Beef Nihari',
      cuisine: 'Pakistani',
      cookTime: '180 mins',
      difficulty: 'Hard',
      calories: 580,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDOpJ06-ATau2KDjMyVBgv9bMsiq74v-FRIbGElv9JOu_6mtYn34geDHtKwwEdXVq-y4juBqN9N5QYeNkAQm1oPUtT2Kx_fSzsfVtoS-qUdWwefmcIHsLKnDedORUi_TW5gATS3Xozp2NgxwWVQhfpWE1vTfJxkm6mzkLAAeRWDE_8GZlSVHPR8JaGO4fbrifhcca_LciG5lfpBwUaMQf886HGT72_a1dIQaM8RXm-UAcdsjAHSlriybFLSZ0l-jV_g-PJBM9nStVs',
      description: 'Slow-cooked beef stew with aromatic spices.',
      searchKeywords: <String>['beef', 'stew', 'nihari', 'pakistani', 'slow cook'],
      ingredients: const <String>[],
      steps: const <String>[],
    ),
    Recipe(
      id: '9',
      name: 'Harvest Quinoa Bowl with Smashed Avocado',
      cuisine: 'Healthy',
      cookTime: '25 mins',
      difficulty: 'Easy',
      calories: 420,
      tag: 'Best Match',
      showAiBadge: true,
      description:
          'A nutrient-dense masterpiece that uses most of your scanned ingredients. High protein and perfectly balanced.',
      imageUrl:
          'https://brokebankvegan.com/wp-content/uploads/2023/09/Harvest-Bowl-15.jpg',
      searchKeywords: <String>[
        'quinoa',
        'avocado',
        'bowl',
        'harvest',
        'healthy',
      ],
      ingredients: const <String>[
        'Quinoa',
        'Avocado',
        'Spinach',
        'Tomatoes',
        'Bell Pepper',
        'Carrots',
      ],
      steps: const <String>[
        'Cook quinoa according to package instructions.',
        'Roast bell peppers and carrots at 200°C for 20 mins.',
        'Smash avocado with lemon juice and salt.',
        'Assemble bowl with quinoa base, roasted veggies, and avocado.',
        'Garnish with fresh spinach and sliced tomatoes.',
      ],
      proteinG: 18,
      carbsG: 45,
      fatsG: 22,
      fiberG: 12,
      ingredientLines: const <RecipeIngredientLine>[
        RecipeIngredientLine(
          name: 'Cooked Quinoa',
          amountAtTwoServings: 200,
          unit: 'g',
          preparation: 'cooked & fluffed',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuAaYAZDWqToXt4JFcUAUNX8jaoQsW5WuxkrOwUtEN3lOVEMEGCFjH99ndBoIHEIsL7TZ7D6QCrkr4-GhiHQgS8z5K-95WHiM4_dWkY3aTXFh4RYpCJg_gYU1jK5e8ZVLKjIFSVCO4Yg-BgCwPMMs5IjE333k21l6DfoaSnhvmLl_oHHxSx5EtFp4bY8NO6B8eSmPK-AEtAeUHBf2qr5wEFoDPR01a5gNEj5f8A-w32i_Wh1pYolqM6MhaCTVC3VSpuoPV-YFmBAvdI',
        ),
        RecipeIngredientLine(
          name: 'Ripe Avocado',
          amountAtTwoServings: 1,
          unit: 'large',
          preparation: 'pitted & smashed',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuDb0-mcgEL8Cl13IqiIp-ZRtqXR0KHvEZqXrEUCpU22K3LpMT-n9hef9efc4CFt5ldvpzF8E0-_xrB4-wZ6MsH866Vjmc6xS2adAggiscMch_-ae5BzJGJ5zvghqgkTBgeH71SjbHXCNWQwBwh3vlIVN31eYGyXrBeuhdkcsYVE3tN6hwUwNUg6fPg20N31ejUd1DhQtrFnV_BRuInZOiIB3qaiKY6mvOtDlyc9plBXsy3ZV7Oxf8Y8sYJktxD-PlTl2g5AWzbY4Dk',
        ),
        RecipeIngredientLine(
          name: 'Baby Spinach',
          amountAtTwoServings: 2,
          unit: 'cups',
          preparation: 'fresh',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuCy_3Aivq0SFY183M3eJjKjdT8N6S_w35paKXstY6p80xTg-ghn7QR7HXcg8sqaDAdExzKlJljg0Op0nPbJWSOPZsq9ZB_G4YPNFVfyCzdHatPxLJPGn_DaoWgIq30j1N8EQQ3DqxR0HX0cMX1vUn4N7v8POP02V36uktybrTTN17rzVvq75p9pIfKoY1uNgKFoustAAY7sMb8urVQ40NRHbnxdnxa_MdCDIeI0PiJ6m8aIToGqh-D09sGMpz_YI7ivQhDxBCtcCpo',
        ),
        RecipeIngredientLine(
          name: 'Cherry Tomatoes',
          amountAtTwoServings: 150,
          unit: 'g',
          preparation: 'halved',
        ),
        RecipeIngredientLine(
          name: 'Bell Pepper',
          amountAtTwoServings: 1,
          unit: 'medium',
          preparation: 'roasted',
        ),
        RecipeIngredientLine(
          name: 'Carrots',
          amountAtTwoServings: 120,
          unit: 'g',
          preparation: 'roasted sticks',
        ),
        RecipeIngredientLine(
          name: 'Lemon Tahini Dressing',
          amountAtTwoServings: 3,
          unit: 'tbsp',
          preparation: 'whisked',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuAqwVOZ5qPFBIvC3WEeQeDCiW2J0jXQczN43XGasM7pO3q7z8c9MyZYn0tICJJute3HGtbm9H9uh_juUxt9A68aeSLVNiPdMY_mfETuqltbWhavCK-HVVE0G1sYyqPWl39t1K3foAU1sxQDgFm8URovR80Qoj2wWhRvgbatLuchu8hyiHshwuZQSJZD-3p_ajIVZisysGxmn72jpJwvoyXrD150y2KRVPzf1_CWqCcoRTeQDJl4fS1fxcQovVCtYzcNdPVLySB16XM',
        ),
      ],
      cookingSteps: const <RecipeCookingStep>[
        RecipeCookingStep(
          title: 'Cook the Quinoa',
          body:
              'Rinse quinoa and cook according to package instructions until fluffy. Let cool slightly.',
        ),
        RecipeCookingStep(
          title: 'Roast the Vegetables',
          body:
              'Preheat oven to 200°C. Toss bell pepper and carrots with olive oil, salt, and pepper. Roast 18–22 minutes until tender.',
        ),
        RecipeCookingStep(
          title: 'Smashed Avocado',
          body:
              'Mash avocado with lemon juice, salt, and a pinch of pepper until mostly smooth with some chunks.',
        ),
        RecipeCookingStep(
          title: 'Assemble the Bowl',
          body:
              'Layer quinoa, roasted vegetables, spinach, and tomatoes in shallow bowls. Add a dollop of smashed avocado.',
        ),
        RecipeCookingStep(
          title: 'Finishing Touch',
          body:
              'Drizzle tahini dressing generously and top with fresh herbs or sesame seeds if desired.',
        ),
      ],
    ),
    Recipe(
      id: '10',
      name: '10-Min Summer Salad',
      cuisine: 'Mediterranean',
      cookTime: '10 mins',
      difficulty: 'Easy',
      calories: 180,
      tag: 'Quickest',
      description: 'Fresh salad with tomatoes, spinach, and bell pepper.',
      imageUrl:
          'https://nutritionrefined.com/wp-content/uploads/2023/08/homemade-garden-salad-featured.jpg',
      searchKeywords: <String>['salad', 'summer', 'quick', 'mediterranean'],
      ingredients: const <String>[
        'Tomatoes',
        'Spinach',
        'Bell Pepper',
        'Basil',
      ],
      steps: const <String>[
        'Wash and chop tomatoes, spinach, and bell pepper.',
        'Combine in a large bowl.',
        'Dress with olive oil, salt, and fresh basil.',
        'Toss and serve immediately.',
      ],
      proteinG: 5,
      carbsG: 12,
      fatsG: 8,
      fiberG: 4,
      ingredientLines: const <RecipeIngredientLine>[
        RecipeIngredientLine(
          name: 'Tomatoes',
          amountAtTwoServings: 250,
          unit: 'g',
          preparation: 'chopped',
        ),
        RecipeIngredientLine(
          name: 'Baby Spinach',
          amountAtTwoServings: 2,
          unit: 'cups',
          preparation: 'washed',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuCy_3Aivq0SFY183M3eJjKjdT8N6S_w35paKXstY6p80xTg-ghn7QR7HXcg8sqaDAdExzKlJljg0Op0nPbJWSOPZsq9ZB_G4YPNFVfyCzdHatPxLJPGn_DaoWgIq30j1N8EQQ3DqxR0HX0cMX1vUn4N7v8POP02V36uktybrTTN17rzVvq75p9pIfKoY1uNgKFoustAAY7sMb8urVQ40NRHbnxdnxa_MdCDIeI0PiJ6m8aIToGqh-D09sGMpz_YI7ivQhDxBCtcCpo',
        ),
        RecipeIngredientLine(
          name: 'Bell Pepper',
          amountAtTwoServings: 1,
          unit: 'medium',
          preparation: 'diced',
        ),
        RecipeIngredientLine(
          name: 'Fresh Basil',
          amountAtTwoServings: 0.5,
          unit: 'cup',
          preparation: 'torn leaves',
        ),
        RecipeIngredientLine(
          name: 'Olive Oil',
          amountAtTwoServings: 2,
          unit: 'tbsp',
          preparation: 'extra virgin',
        ),
      ],
      cookingSteps: const <RecipeCookingStep>[
        RecipeCookingStep(
          title: 'Prep the Vegetables',
          body:
              'Wash and chop tomatoes, spinach, and bell pepper into bite-sized pieces.',
        ),
        RecipeCookingStep(
          title: 'Combine',
          body: 'Add everything to a large mixing bowl.',
        ),
        RecipeCookingStep(
          title: 'Dress & Toss',
          body:
              'Drizzle olive oil, season with salt, and tear basil over the top. Toss gently and serve immediately.',
        ),
      ],
    ),
    Recipe(
      id: '11',
      name: 'Pesto Pasta Primavera',
      cuisine: 'Italian',
      cookTime: '15 mins',
      difficulty: 'Easy',
      calories: 380,
      tag: '',
      description: 'Fresh vegetables tossed with pasta and basil pesto.',
      imageUrl:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQwKvNw7Gb4Io-jBJ3vPiR-MnacgopgP6bZBw&s',
      searchKeywords: <String>['pesto', 'pasta', 'italian', 'primavera'],
      ingredients: const <String>[
        'Spinach',
        'Tomatoes',
        'Bell Pepper',
        'Basil',
        'Onion',
      ],
      steps: const <String>[
        'Boil pasta until al dente.',
        'Sauté onion and bell pepper in olive oil.',
        'Add spinach and tomatoes, cook 2 mins.',
        'Blend basil with olive oil for quick pesto.',
        'Toss pasta with vegetables and pesto.',
      ],
      proteinG: 12,
      carbsG: 58,
      fatsG: 14,
      fiberG: 6,
      ingredientLines: const <RecipeIngredientLine>[
        RecipeIngredientLine(
          name: 'Dry Pasta',
          amountAtTwoServings: 200,
          unit: 'g',
          preparation: 'any short shape',
        ),
        RecipeIngredientLine(
          name: 'Yellow Onion',
          amountAtTwoServings: 0.5,
          unit: 'medium',
          preparation: 'diced',
        ),
        RecipeIngredientLine(
          name: 'Bell Pepper',
          amountAtTwoServings: 1,
          unit: 'medium',
          preparation: 'sliced',
        ),
        RecipeIngredientLine(
          name: 'Cherry Tomatoes',
          amountAtTwoServings: 150,
          unit: 'g',
          preparation: 'halved',
        ),
        RecipeIngredientLine(
          name: 'Spinach',
          amountAtTwoServings: 2,
          unit: 'cups',
          preparation: 'packed',
        ),
        RecipeIngredientLine(
          name: 'Fresh Basil',
          amountAtTwoServings: 1,
          unit: 'cup',
          preparation: 'for pesto',
        ),
        RecipeIngredientLine(
          name: 'Olive Oil',
          amountAtTwoServings: 4,
          unit: 'tbsp',
          preparation: 'for sauté & pesto',
        ),
      ],
      cookingSteps: const <RecipeCookingStep>[
        RecipeCookingStep(
          title: 'Boil Pasta',
          body:
              'Cook pasta in salted water until al dente. Reserve a splash of pasta water, then drain.',
        ),
        RecipeCookingStep(
          title: 'Sauté Vegetables',
          body:
              'Warm olive oil in a large pan. Cook onion and bell pepper until softened.',
        ),
        RecipeCookingStep(
          title: 'Add Greens & Tomatoes',
          body:
              'Stir in spinach and tomatoes; cook about 2 minutes until spinach wilts.',
        ),
        RecipeCookingStep(
          title: 'Quick Pesto',
          body:
              'Blend basil with olive oil, garlic if desired, and a pinch of salt for a simple pesto.',
        ),
        RecipeCookingStep(
          title: 'Toss Together',
          body:
              'Combine pasta, vegetables, and pesto. Add pasta water to loosen if needed.',
        ),
      ],
    ),
    Recipe(
      id: '12',
      name: 'Lemon Garlic Salmon',
      cuisine: 'Healthy',
      cookTime: '25 mins',
      difficulty: 'Intermediate',
      calories: 320,
      tag: '',
      description: 'Seared salmon with lemon and garlic, served over vegetables.',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBHxeHUxKgXsBEiEnWj83k1WTOpM7KVxOHIlhEMYUFl0emAzE8rpik_rkcrN51C-SvnyhtncGVKvL71xECwu9cVF7s26Ljea5NiBBAYpoARrNqXyWcavzrljHGsP7ipMIq1eqDj8020p3ZlrtYZNymj92lvZeqQtEAyfsT4bbzU03Usa14PnYZ35yxoIvGz6yckQSr7wx47p3QGn1ON2FWJLCpjB4GszE5vg9yLMGxZC9mAAzak9v-z18csy1MR4RCBStHdolcvfHo',
      searchKeywords: <String>['salmon', 'lemon', 'garlic', 'fish'],
      ingredients: const <String>[
        'Spinach',
        'Carrots',
        'Onion',
        'Bell Pepper',
      ],
      steps: const <String>[
        'Season salmon with lemon juice, garlic, salt and pepper.',
        'Heat pan with olive oil on medium-high.',
        'Sear salmon 4 mins each side.',
        'Sauté spinach, carrots, onion as side.',
        'Plate salmon over vegetables with lemon wedge.',
      ],
      proteinG: 32,
      carbsG: 8,
      fatsG: 18,
      fiberG: 3,
      ingredientLines: const <RecipeIngredientLine>[
        RecipeIngredientLine(
          name: 'Salmon Fillets',
          amountAtTwoServings: 2,
          unit: 'fillets',
          preparation: 'skin-on optional',
        ),
        RecipeIngredientLine(
          name: 'Lemon',
          amountAtTwoServings: 1,
          unit: 'whole',
          preparation: 'juiced & wedges',
        ),
        RecipeIngredientLine(
          name: 'Garlic',
          amountAtTwoServings: 3,
          unit: 'cloves',
          preparation: 'minced',
        ),
        RecipeIngredientLine(
          name: 'Baby Spinach',
          amountAtTwoServings: 2,
          unit: 'cups',
          preparation: 'sautéed',
        ),
        RecipeIngredientLine(
          name: 'Carrots',
          amountAtTwoServings: 150,
          unit: 'g',
          preparation: 'sliced',
        ),
        RecipeIngredientLine(
          name: 'Onion',
          amountAtTwoServings: 0.5,
          unit: 'medium',
          preparation: 'sliced',
        ),
        RecipeIngredientLine(
          name: 'Bell Pepper',
          amountAtTwoServings: 1,
          unit: 'small',
          preparation: 'strips',
        ),
      ],
      cookingSteps: const <RecipeCookingStep>[
        RecipeCookingStep(
          title: 'Season the Salmon',
          body:
              'Pat salmon dry. Season with lemon juice, garlic, salt, and black pepper.',
        ),
        RecipeCookingStep(
          title: 'Sear',
          body:
              'Heat olive oil in a skillet over medium-high. Sear salmon about 4 minutes per side until cooked through.',
        ),
        RecipeCookingStep(
          title: 'Sauté the Vegetables',
          body:
              'In the same pan, cook carrots and onion until tender. Add bell pepper and spinach; wilt spinach.',
        ),
        RecipeCookingStep(
          title: 'Plate',
          body:
              'Serve salmon over vegetables with extra lemon wedges.',
        ),
      ],
    ),
  ];

  static Recipe get recipeChanaChaat => mockRecipes[5];
  static Recipe get recipeSeekhKebabs => mockRecipes[6];
  static Recipe get recipeBeefNihari => mockRecipes[7];

  static List<Recipe> get curatedRecipes => <Recipe>[
        recipeChanaChaat,
        recipeSeekhKebabs,
        recipeBeefNihari,
      ];

  static Recipe? recipeById(String id) {
    for (final Recipe r in mockRecipes) {
      if (r.id == id) {
        return r;
      }
    }
    return null;
  }
}
