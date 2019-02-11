// handles all syncing with K2 database

// co-ordinates data between repositories

// Loads new job from remote, including all samples etc.

import 'package:camera/camera.dart';
import 'package:k2e/model/jobheader.dart';
import 'package:k2e/utils/timesheet.dart';

class DataManager {

  static final DataManager _dm = new DataManager._internal();
  // Temp Storage
//  List<JobHeader> myJobCache;
  List<JobHeader> wfmJobCache = new List(); // this holds all jobs gathered from the last WFM api request

  List<CameraDescription> cameras;
  String user;
  String currentJobPath;
  String currentJobNumber;
  List<Map<String, String>> currentJobSamples;
  TimeCounter currentTimeCounter;

  // Current State
  String currentRoom;
  String currentRoomGroup;

  // Autocompletes
  Map constants;

  // Job templates
  List roomGroupTemplates =
    [
      {'name': '-'},
      {
        'name': 'Management: 3 Bedroom House',
        'rooms': [
          { 'name': 'Kitchen', 'template': 'Kitchen', },
          { 'name': 'Lounge', 'template': 'Lounge', },
          { 'name': 'Dining Room', 'template': 'Basic', },
          { 'name': 'Hallway', 'template': 'Hallway', },
          { 'name': 'Bathroom', 'template': 'Bathroom/Toilet', },
          { 'name': 'Toilet', 'template': 'Bathroom/Toilet', },
          { 'name': 'Laundry', 'template': 'Bathroom/Toilet', },
          { 'name': 'Bedroom 1', 'template': 'Basic', },
          { 'name': 'Bedroom 2', 'template': 'Basic', },
          { 'name': 'Bedroom 3', 'template': 'Basic', },
          { 'name': 'Ceiling Space', 'template': 'Basic', 'acm': [
            {'description': 'Surfaces', 'material': 'dust', }
          ]},
          { 'name': 'Exterior', 'template': 'Basic', },
          { 'name': 'Garage', 'template': 'Basic', },
          { 'name': 'Shed', 'template': 'Basic', },
        ],
      },
      {
        'name': 'Demolition: 3 Bedroom House',
        'rooms': [
          { 'name': 'Kitchen', 'template': 'Kitchen', },
          { 'name': 'HWC', 'template': 'Basic', },
          { 'name': 'Lounge', 'template': 'Lounge', },
          { 'name': 'Fireplace', 'template': 'Basic', },
          { 'name': 'Dining Room', 'template': 'Basic', },
          { 'name': 'Hallway', 'template': 'Hallway', },
          { 'name': 'Fuse Board', 'template': 'Basic', },
          { 'name': 'Bathroom', 'template': 'Bathroom/Toilet', },
          { 'name': 'Toilet', 'template': 'Bathroom/Toilet', },
          { 'name': 'Laundry', 'template': 'Bathroom/Toilet', },
          { 'name': 'Bedroom 1', 'template': 'Basic', },
          { 'name': 'Bedroom 2', 'template': 'Basic', },
          { 'name': 'Bedroom 3', 'template': 'Basic', },
          { 'name': 'Ceiling Space', 'template': 'Basic', 'acm': [
            {'description': 'Surfaces', 'material': 'dust', }
          ]},
          { 'name': 'Exterior', 'template': 'Basic', 'acm': [
            { 'description': 'Soil', 'material': 'soil', }
          ]},
          { 'name': 'Garage', 'template': 'Basic', },
          { 'name': 'Shed', 'template': 'Basic', },
        ],
      },
      {'name': 'Locomotive Type DC'},
      {'name': 'Locomotive Type DCP'},
      {'name': 'Locomotive Type DFM'},
      {'name': 'Locomotive Type DFT'},
      {'name': 'Locomotive Type DH'},
      {'name': 'Locomotive Type DSC'},
      {'name': 'Locomotive Type DXB'},
      {'name': 'Locomotive Type EF'},
      {'name': 'Electrical Substation'},
    ];

  List roomTemplates =
  [
    {
      "name": "Blank Rows",
      "buildingmaterials": [
        {
          "label": "",
          "material": "",
        },
        {
          "label": "",
          "material": "",
        },
        {
          "label": "",
          "material": "",
        },
        {
          "label": "",
          "material": "",
        },
        {
          "label": "",
          "material": "",
        },
        {
          "label": "",
          "material": "",
        },
        {
          "label": "",
          "material": "",
        },
        {
          "label": "",
          "material": "",
        },
        {
          "label": "",
          "material": "",
        },
        {
          "label": "",
          "material": "",
        },
      ]
    },
    {
      "name": "Basic",
      "buildingmaterials": [
        {
          "label": "Ceiling",
          "material": "",
        },
        {
          "label": "Walls",
          "material": "",
        },
        {
          "label": "Floor",
          "material": "",
        },
      ],
    },
    {
      "name": "Hallway",
      "buildingmaterials": [
        {
          "label": "Ceiling",
          "material": "",
        },
        {
          "label": "Walls",
          "material": "",
        },
        {
          "label": "Fuse board",
          "material": "",
        },
        {
          "label": "Hot water cylinder",
          "material": "",
        },
        {
          "label": "Entry floor",
          "material": "",
        },
        {
          "label": "Floor",
          "material": "",
        },
      ],
    },
    {
      "name": "Kitchen",
      "buildingmaterials": [
        {
          "label": "Ceiling",
          "material": "",
        },
        {
          "label": "Walls",
          "material": "",
        },
        {
          "label": "Rangehood",
          "material": "",
        },
        {
          "label": "Hot Water Cylinder",
          "material": "",
        },
        {
          "label": "Bench",
          "material": "",
        },
        {
          "label": "Splashback",
          "material": "",
        },
        {
          "label": "Sink",
          "material": "",
        },
        {
          "label": "Pipework",
          "material": "",
        },
        {
          "label": "Sink",
          "material": "",
        },
        {
          "label": "Floor",
          "material": "",
        },
      ],
    },
    {
      "name": "Lounge",
      "buildingmaterials": [
        {
          "label": "Ceiling",
          "material": "",
        },
        {
          "label": "Walls",
          "material": "",
        },
        {
          "label": "Fireplace",
          "material": "",
        },
        {
          "label": "Heat pump",
          "material": "",
        },
        {
          "label": "Floor",
          "material": "",
        },
      ],
    },
    {
      "name": "Bathroom/Toilet",
      "buildingmaterials": [
        {
          "label": "Ceiling",
          "material": "",
        },
        {
          "label": "Walls",
          "material": "",
        },
        {
          "label": "Bath surround",
          "material": "",
        },
        {
          "label": "Bath",
          "material": "",
        },
        {
          "label": "Toilet",
          "material": "",
        },
        {
          "label": "Pipework",
          "material": "",
        },
        {
          "label": "Floor",
          "material": "",
        },
      ],
    },
  ];

  static DataManager get() {
    return _dm;
  }

  DataManager._internal(){

  }
}
