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
  TArrowKeyDirectionEnum = (kdLeft, kdRight, kdUp, kdDown);

const
  PositionTransitions: array [TArrowKeyDirectionEnum, 0 .. 5] of Integer = (
    // Left
    (3, 4, 5, 0, 1, 2),
    // Right
    (3, 4, 5, 0, 1, 2),
    // Up
    (2, 0, 1, 5, 3, 4),
    // Down
    (1, 2, 0, 4, 5, 3)
    //
    );

implementation

end.
