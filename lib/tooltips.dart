class ToolTip {
  final String title;
  final String tip;
  final String subtip;

  ToolTip ({
    this.title,
    this.tip,
    this.subtip
  });
}

class Tip {
  // MATERIAL RISK

  // ACCESSIBILITY
  static final accessibility_easy = new ToolTip(
    title: 'Accessibility: Easy',
    tip: 'May be disturbed during normal occupancy. Does not require any access equipment to access.',
    subtip: 'Ground floor wall cladding, floor coverings, etc.',
  );

  static final accessibility_medium = new ToolTip(
    title: 'Accessibility: Medium',
    tip: 'Requires equipment (e.g. a ladder) to access. Within fuse boxes.',
    subtip: 'Ground floor soffits, fuse box lining, interior ceilings, etc.',
  );

  static final accessibility_difficult = new ToolTip(
    title: 'Accessibility: Difficult',
    tip: 'Requires specialist equipment, dismantling of machinery or modification of the building to access.',
    subtip: 'Above false ceilings, within walls, upper floor soffits and gables, cylinder insulation, etc.',
  );

  // PRODUCT
  static final material_product_1 = new ToolTip(
    title: 'Product Score: 1',
    tip: 'Non-friable or low friability.',
    subtip: 'Fibre cement, vinyl tiles, plaster, etc.',
  );

  static final material_product_2 = new ToolTip(
    title: 'Product Score: 2',
    tip: 'Medium friability',
    subtip: 'Asbestos rope and textiles, paper-backed vinyl, gaskets, asbestos insulation board, millboard, etc.',
  );

  static final material_product_3 = new ToolTip(
    title: 'Product Score: 3',
    tip: 'Highly friable.',
    subtip: 'Asbestos-contaminated dust or soil, loose asbestos, insulation, etc.',
  );

  // DAMAGE
  static final material_damage_0 = new ToolTip(
    title: 'Damage Score: 0',
    tip: 'No visible damage',
    subtip: '',
  );

  static final material_damage_1 = new ToolTip(
    title: 'Damage Score: 1',
    tip: 'Low damage',
    subtip: '',
  );

  static final material_damage_2 = new ToolTip(
    title: 'Damage Score: 2',
    tip: 'Moderate damage',
    subtip: '',
  );

  static final material_damage_3 = new ToolTip(
    title: 'Damage Score: 3',
    tip: 'High damage',
    subtip: '',
  );

  // SURFACE
  static final material_surface_0 = new ToolTip(
    title: 'Surface Treatment Score: 0',
    tip: 'Composite material',
    subtip: '',
  );

  static final material_surface_1 = new ToolTip(
    title: 'Surface Treatment Score: 1',
    tip: 'Non-friable material',
    subtip: '',
  );

  static final material_surface_2 = new ToolTip(
    title: 'Surface Treatment Score: 2',
    tip: 'Sealed friable material',
    subtip: '',
  );

  static final material_surface_3 = new ToolTip(
    title: 'Surface Treatment Score: 3',
    tip: 'Unsealed friable material',
    subtip: '',
  );

  // ASBESTOS
  static final material_asbestos_1 = new ToolTip(
    title: 'Asbestos Type Score: 1',
    tip: 'Only chrysotile asbestos detected',
    subtip: '',
  );

  static final material_asbestos_2 = new ToolTip(
    title: 'Asbestos Type Score: 2',
    tip: 'Amphibole asbestos detected, except crocidolite',
    subtip: '',
  );

  static final material_asbestos_3 = new ToolTip(
    title: 'Asbestos Type Score: 3',
    tip: 'Asbestos type unknown or crocidolite asbestos detected',
    subtip: '',
  );

  //
  // PRIORITY RISK
  //

  //
}