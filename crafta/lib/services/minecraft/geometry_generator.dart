import 'dart:convert';
import '../../models/minecraft/addon_file.dart';
import '../../models/minecraft/addon_metadata.dart';

/// Generates Minecraft geometry (3D models) for creatures
/// For MVP: Uses simple box-based templates
class GeometryGenerator {
  /// Generate geometry file for a creature type
  static AddonFile generateGeometry({
    required String creatureType,
    required AddonMetadata metadata,
  }) {
    final geometryId = 'geometry.${metadata.namespace}.$creatureType';

    Map<String, dynamic> geometryData;

    switch (creatureType.toLowerCase()) {
      case 'cow':
        geometryData = _getCowGeometry(geometryId);
        break;
      case 'pig':
        geometryData = _getPigGeometry(geometryId);
        break;
      case 'chicken':
        geometryData = _getChickenGeometry(geometryId);
        break;
      case 'dragon':
        geometryData = _getDragonGeometry(geometryId);
        break;
      case 'unicorn':
        geometryData = _getUnicornGeometry(geometryId);
        break;
      case 'horse':
        geometryData = _getHorseGeometry(geometryId);
        break;
      default:
        geometryData = _getGenericGeometry(geometryId);
    }

    final jsonString = const JsonEncoder.withIndent('  ').convert(geometryData);
    return AddonFile.json('models/entity/$creatureType.geo.json', jsonString);
  }

  /// Generic creature geometry (box-based)
  static Map<String, dynamic> _getGenericGeometry(String geometryId) {
    return {
      'format_version': '1.12.0',
      'minecraft:geometry': [
        {
          'description': {
            'identifier': geometryId,
            'texture_width': 64,
            'texture_height': 64,
            'visible_bounds_width': 2,
            'visible_bounds_height': 2.5,
            'visible_bounds_offset': [0, 1, 0],
          },
          'bones': [
            {
              'name': 'body',
              'pivot': [0, 12, 0],
              'cubes': [
                {
                  'origin': [-4, 8, -4],
                  'size': [8, 8, 8],
                  'uv': [0, 16],
                }
              ]
            },
            {
              'name': 'head',
              'parent': 'body',
              'pivot': [0, 16, -4],
              'cubes': [
                {
                  'origin': [-3, 16, -7],
                  'size': [6, 6, 6],
                  'uv': [0, 0],
                }
              ]
            },
          ]
        }
      ]
    };
  }

  /// Cow geometry
  static Map<String, dynamic> _getCowGeometry(String geometryId) {
    return {
      'format_version': '1.12.0',
      'minecraft:geometry': [
        {
          'description': {
            'identifier': geometryId,
            'texture_width': 64,
            'texture_height': 32,
          },
          'bones': [
            {
              'name': 'body',
              'pivot': [0, 19, 2],
              'cubes': [
                {
                  'origin': [-6, 11, -5],
                  'size': [12, 18, 10],
                  'uv': [18, 4],
                }
              ]
            },
            {
              'name': 'head',
              'parent': 'body',
              'pivot': [0, 20, -8],
              'cubes': [
                {
                  'origin': [-4, 16, -14],
                  'size': [8, 8, 6],
                  'uv': [0, 0],
                }
              ]
            },
            {
              'name': 'leg0',
              'parent': 'body',
              'pivot': [-4, 12, 7],
              'cubes': [
                {
                  'origin': [-6, 0, 5],
                  'size': [4, 12, 4],
                  'uv': [0, 16],
                }
              ]
            },
            {
              'name': 'leg1',
              'parent': 'body',
              'pivot': [4, 12, 7],
              'cubes': [
                {
                  'origin': [2, 0, 5],
                  'size': [4, 12, 4],
                  'uv': [0, 16],
                }
              ]
            },
            {
              'name': 'leg2',
              'parent': 'body',
              'pivot': [-4, 12, -6],
              'cubes': [
                {
                  'origin': [-6, 0, -7],
                  'size': [4, 12, 4],
                  'uv': [0, 16],
                }
              ]
            },
            {
              'name': 'leg3',
              'parent': 'body',
              'pivot': [4, 12, -6],
              'cubes': [
                {
                  'origin': [2, 0, -7],
                  'size': [4, 12, 4],
                  'uv': [0, 16],
                }
              ]
            },
          ]
        }
      ]
    };
  }

  /// Pig geometry
  static Map<String, dynamic> _getPigGeometry(String geometryId) {
    return {
      'format_version': '1.12.0',
      'minecraft:geometry': [
        {
          'description': {
            'identifier': geometryId,
            'texture_width': 64,
            'texture_height': 32,
          },
          'bones': [
            {
              'name': 'body',
              'pivot': [0, 13, 2],
              'cubes': [
                {
                  'origin': [-5, 7, -5],
                  'size': [10, 16, 8],
                  'uv': [28, 8],
                }
              ]
            },
            {
              'name': 'head',
              'parent': 'body',
              'pivot': [0, 12, -6],
              'cubes': [
                {
                  'origin': [-4, 8, -14],
                  'size': [8, 8, 8],
                  'uv': [0, 0],
                },
                {
                  'origin': [-2, 9, -15],
                  'size': [4, 3, 1],
                  'uv': [16, 16],
                }
              ]
            },
          ]
        }
      ]
    };
  }

  /// Chicken geometry
  static Map<String, dynamic> _getChickenGeometry(String geometryId) {
    return {
      'format_version': '1.12.0',
      'minecraft:geometry': [
        {
          'description': {
            'identifier': geometryId,
            'texture_width': 64,
            'texture_height': 32,
          },
          'bones': [
            {
              'name': 'body',
              'pivot': [0, 8, 0],
              'cubes': [
                {
                  'origin': [-3, 4, -3],
                  'size': [6, 8, 6],
                  'uv': [0, 9],
                }
              ]
            },
            {
              'name': 'head',
              'parent': 'body',
              'pivot': [0, 11, -4],
              'cubes': [
                {
                  'origin': [-2, 10, -6],
                  'size': [4, 6, 3],
                  'uv': [0, 0],
                }
              ]
            },
          ]
        }
      ]
    };
  }

  /// Dragon geometry (mythical creature)
  static Map<String, dynamic> _getDragonGeometry(String geometryId) {
    return {
      'format_version': '1.12.0',
      'minecraft:geometry': [
        {
          'description': {
            'identifier': geometryId,
            'texture_width': 128,
            'texture_height': 128,
            'visible_bounds_width': 4,
            'visible_bounds_height': 4,
          },
          'bones': [
            {
              'name': 'body',
              'pivot': [0, 16, 0],
              'cubes': [
                {
                  'origin': [-6, 10, -8],
                  'size': [12, 12, 16],
                  'uv': [0, 24],
                }
              ]
            },
            {
              'name': 'head',
              'parent': 'body',
              'pivot': [0, 18, -8],
              'cubes': [
                {
                  'origin': [-4, 14, -16],
                  'size': [8, 8, 8],
                  'uv': [0, 0],
                }
              ]
            },
            {
              'name': 'neck',
              'parent': 'body',
              'pivot': [0, 18, -6],
              'cubes': [
                {
                  'origin': [-3, 14, -10],
                  'size': [6, 6, 6],
                  'uv': [48, 0],
                }
              ]
            },
            {
              'name': 'wingLeft',
              'parent': 'body',
              'pivot': [6, 18, 0],
              'cubes': [
                {
                  'origin': [6, 12, -4],
                  'size': [12, 8, 0.5],
                  'uv': [0, 52],
                }
              ]
            },
            {
              'name': 'wingRight',
              'parent': 'body',
              'pivot': [-6, 18, 0],
              'cubes': [
                {
                  'origin': [-18, 12, -4],
                  'size': [12, 8, 0.5],
                  'uv': [0, 52],
                }
              ]
            },
          ]
        }
      ]
    };
  }

  /// Unicorn geometry (horse-based with horn)
  static Map<String, dynamic> _getUnicornGeometry(String geometryId) {
    return {
      'format_version': '1.12.0',
      'minecraft:geometry': [
        {
          'description': {
            'identifier': geometryId,
            'texture_width': 64,
            'texture_height': 64,
          },
          'bones': [
            {
              'name': 'body',
              'pivot': [0, 13, 6],
              'cubes': [
                {
                  'origin': [-5, 11, -11],
                  'size': [10, 10, 22],
                  'uv': [0, 32],
                }
              ]
            },
            {
              'name': 'head',
              'parent': 'body',
              'pivot': [0, 20, -10],
              'cubes': [
                {
                  'origin': [-3, 17, -20],
                  'size': [6, 8, 10],
                  'uv': [0, 0],
                }
              ]
            },
            {
              'name': 'horn',
              'parent': 'head',
              'pivot': [0, 25, -16],
              'cubes': [
                {
                  'origin': [-0.5, 25, -16.5],
                  'size': [1, 5, 1],
                  'uv': [0, 18],
                }
              ]
            },
          ]
        }
      ]
    };
  }

  /// Horse geometry
  static Map<String, dynamic> _getHorseGeometry(String geometryId) {
    return {
      'format_version': '1.12.0',
      'minecraft:geometry': [
        {
          'description': {
            'identifier': geometryId,
            'texture_width': 64,
            'texture_height': 64,
          },
          'bones': [
            {
              'name': 'body',
              'pivot': [0, 13, 6],
              'cubes': [
                {
                  'origin': [-5, 11, -11],
                  'size': [10, 10, 22],
                  'uv': [0, 32],
                }
              ]
            },
            {
              'name': 'head',
              'parent': 'body',
              'pivot': [0, 20, -10],
              'cubes': [
                {
                  'origin': [-3, 17, -20],
                  'size': [6, 8, 10],
                  'uv': [0, 0],
                }
              ]
            },
            {
              'name': 'neck',
              'parent': 'body',
              'pivot': [0, 16, -6],
              'cubes': [
                {
                  'origin': [-2, 16, -14],
                  'size': [4, 12, 8],
                  'uv': [0, 18],
                }
              ]
            },
          ]
        }
      ]
    };
  }
}
