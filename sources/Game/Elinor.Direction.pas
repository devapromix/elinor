unit Elinor.Direction;

interface

uses
  System.Types;

type
  TDirectionEnum = (drEast, drWest, drSouth, drNorth, drSouthEast, drSouthWest,
    drNorthEast, drNorthWest, drOrigin);

const
  Direction: array [TDirectionEnum] of TPoint = ((X: 1; Y: 0), (X: - 1; Y: 0),
    (X: 0; Y: 1), (X: 0; Y: - 1), (X: 1; Y: 1), (X: - 1; Y: 1), (X: 1; Y: - 1),
    (X: - 1; Y: - 1), (X: 0; Y: 0));

type
  TPositionMatrix = array[TDirectionEnum, 0..11] of Integer;

const
  PositionTransitions: TPositionMatrix = (
    // East (drEast)
    (6, 0, 8, 2, 10, 4, 7, 1, 9, 3, 11, 5),
    // West (drWest)
    (1, 7, 3, 9, 5, 11, 0, 6, 2, 8, 4, 10),
    // South (drSouth)
    (2, 3, 4, 5, 0, 1, 8, 9, 10, 11, 6, 7),
    // North (drNorth)
    (4, 5, 0, 1, 2, 3, 10, 11, 6, 7, 8, 9),
    // SouthEast (drSouthEast)
    (2, 3, 4, 5, 0, 1, 8, 9, 10, 11, 6, 7),
    // SouthWest (drSouthWest)
    (6, 0, 7, 2, 8, 4, 1, 3, 9, 5, 10, 11),
    // NorthEast (drNorthEast)
    (1, 7, 3, 9, 5, 11, 0, 6, 2, 8, 4, 10),
    // NorthWest (drNorthWest)
    (6, 0, 7, 2, 8, 4, 1, 3, 9, 5, 10, 11),
    // Origin (drOrigin)
    (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11)
  );

implementation

end.
