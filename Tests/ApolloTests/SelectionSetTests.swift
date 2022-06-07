import XCTest
@testable import Apollo
@testable import ApolloAPI
import ApolloInternalTestHelpers
import Nimble

class SelectionSetTests: XCTestCase {

  func test__selection_givenOptionalField_givenValue__returnsValue() {
    // given
    class Hero: MockSelectionSet, SelectionSet {
      typealias Schema = MockSchemaConfiguration

      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .field("name", String?.self)
      ]}

      var name: String? { data["name"] }
    }

    let object: JSONObject = [
      "__typename": "Human",
      "name": "Johnny Tsunami"
    ]

    // when
    let actual = Hero(data: DataDict(object, variables: nil))

    // then
    expect(actual.name).to(equal("Johnny Tsunami"))
  }

  func test__selection_givenOptionalField_givenNilValue__returnsNil() {
    // given
    class Hero: MockSelectionSet, SelectionSet {
      typealias Schema = MockSchemaConfiguration

      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .field("name", String?.self)
      ]}

      var name: String? { data["name"] }
    }

    let object: JSONObject = [
      "__typename": "Human"
    ]

    // when
    let actual = Hero(data: DataDict(object, variables: nil))

    // then
    expect(actual.name).to(beNil())
  }

  // MARK: Scalar - Nested Array Tests

  func test__selection__nestedArrayOfScalar_nonNull_givenValue__returnsValue() {
    // given
    class Hero: MockSelectionSet, SelectionSet {
      typealias Schema = MockSchemaConfiguration

      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .field("nestedList", [[String]].self)
      ]}

      var nestedList: [[String]] { data["nestedList"] }
    }

    let object: JSONObject = [
      "__typename": "Human",
      "nestedList": [["A"]]
    ]

    // when
    let actual = Hero(data: DataDict(object, variables: nil))

    // then
    expect(actual.nestedList).to(equal([["A"]]))
  }

  // MARK: Entity

  func test__selection_givenRequiredEntityField_givenValue__returnsValue() {
    // given
    class Hero: MockSelectionSet, SelectionSet {
      typealias Schema = MockSchemaConfiguration

      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .field("friend", Friend.self)
      ]}

      var friend: Friend { data["friend"] }

      class Friend: MockSelectionSet, SelectionSet {
        typealias Schema = MockSchemaConfiguration

        override class var selections: [Selection] {[
          .field("__typename", String.self),
        ]}
      }
    }

    let friendData: JSONObject = ["__typename": "Human"]

    let object: JSONObject = [
      "__typename": "Human",
      "friend": friendData
    ]

    let expected = Hero.Friend(data: DataDict(friendData, variables: nil))

    // when
    let actual = Hero(data: DataDict(object, variables: nil))

    // then
    expect(actual.friend).to(equal(expected))
  }

  func test__selection_givenOptionalEntityField_givenValue__returnsValue() {
    // given
    class Hero: MockSelectionSet, SelectionSet {
      typealias Schema = MockSchemaConfiguration

      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .field("friend", Hero?.self)
      ]}

      var friend: Hero? { data["friend"] }
    }

    let friendData: JSONObject = ["__typename": "Human"]

    let object: JSONObject = [
      "__typename": "Human",
      "friend": friendData
    ]

    let expected = Hero(data: DataDict(friendData, variables: nil))

    // when
    let actual = Hero(data: DataDict(object, variables: nil))

    // then
    expect(actual.friend).to(equal(expected))
  }

  func test__selection_givenOptionalEntityField_givenNilValue__returnsNil() {
    // given
    class Hero: MockSelectionSet, SelectionSet {
      typealias Schema = MockSchemaConfiguration

      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .field("friend", Hero?.self)
      ]}

      var friend: Hero? { data["friend"] }
    }

    let object: JSONObject = [
      "__typename": "Human"
    ]

    // when
    let actual = Hero(data: DataDict(object, variables: nil))

    // then
    expect(actual.friend).to(beNil())
  }

  // MARK: Entity - Array Tests

  func test__selection__arrayOfEntity_nonNull_givenValue__returnsValue() {
    // given
    class Hero: MockSelectionSet, SelectionSet {
      typealias Schema = MockSchemaConfiguration

      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .field("friends", [Hero].self)
      ]}

      var friends: [Hero] { data["friends"] }
    }

    let object: JSONObject = [
      "__typename": "Human",
      "friends": [
        [
          "__typename": "Human",
          "friends": []
        ]
      ]
    ]

    let expected = Hero(data: DataDict(
      [
        "__typename": "Human",
        "friends": []
      ],
      variables: nil
    ))

    // when
    let actual = Hero(data: DataDict(object, variables: nil))

    // then
    expect(actual.friends).to(equal([expected]))
  }

  func test__selection__arrayOfEntity_nullableEntity_givenValue__returnsValue() {
    // given
    class Hero: MockSelectionSet, SelectionSet {
      typealias Schema = MockSchemaConfiguration

      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .field("friends", [Hero?].self)
      ]}

      var friends: [Hero?] { data["friends"] }
    }

    let object: JSONObject = [
      "__typename": "Human",
      "friends": [
        [
          "__typename": "Human",
          "friends": []
        ]
      ]
    ]

    let expected = Hero(data: DataDict(
      [
        "__typename": "Human",
        "friends": []
      ],
      variables: nil
    ))

    // when
    let actual = Hero(data: DataDict(object, variables: nil))

    // then
    expect(actual.friends).to(equal([expected]))
  }

  func test__selection__arrayOfEntity_nullableEntity_givenNilValueInList__returnsArrayWithNil() {
    // given
    class Hero: MockSelectionSet, SelectionSet {
      typealias Schema = MockSchemaConfiguration

      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .field("friends", [Hero?].self)
      ]}

      var friends: [Hero?] { data["friends"] }
    }

    let object: JSONObject = [
      "__typename": "Human",
      "friends": [
        Hero?.none,
        ["__typename": "Human", "friends": []],
        Hero?.none
      ]
    ]

    let expected = Hero(data: DataDict(
      [
        "__typename": "Human",
        "friends": []
      ],
      variables: nil
    ))

    // when
    let actual = Hero(data: DataDict(object, variables: nil))

    // then
    expect(actual.friends).to(equal([Hero?.none, expected, Hero?.none]))
  }

  func test__selection__arrayOfEntity_nullableList_givenValue__returnsValue() {
    // given
    class Hero: MockSelectionSet, SelectionSet {
      typealias Schema = MockSchemaConfiguration

      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .field("friends", [Hero]?.self)
      ]}

      var friends: [Hero]? { data["friends"] }
    }

    let object: JSONObject = [
      "__typename": "Human",
      "friends": [
        [
          "__typename": "Human",
          "friends": []
        ]
      ]
    ]

    let expected = Hero(data: DataDict(
      [
        "__typename": "Human",
        "friends": []
      ],
      variables: nil
    ))

    // when
    let actual = Hero(data: DataDict(object, variables: nil))

    // then
    expect(actual.friends).to(equal([expected]))
  }

  func test__selection__arrayOfEntity_nullableList_givenNoListValue__returnsNil() {
    // given
    class Hero: MockSelectionSet, SelectionSet {
      typealias Schema = MockSchemaConfiguration

      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .field("friends", [Hero]?.self)
      ]}

      var friends: [Hero]? { data["friends"] }
    }

    let object: JSONObject = [
      "__typename": "Human"
    ]

    // when
    let actual = Hero(data: DataDict(object, variables: nil))

    // then
    expect(actual.friends).to(beNil())
  }

  // MARK: Entity - Nested Array Tests

  func test__selection__nestedArrayOfEntity_nonNull_givenValue__returnsValue() {
    // given
    class Hero: MockSelectionSet, SelectionSet {
      typealias Schema = MockSchemaConfiguration

      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .field("nestedList", [[Hero]].self)
      ]}

      var nestedList: [[Hero]] { data["nestedList"] }
    }

    let object: JSONObject = [
      "__typename": "Human",
      "nestedList": [[
        [
          "__typename": "Human",
          "nestedList": [[]]
        ]
      ]]
    ]

    let expected = Hero(data: DataDict(
      [
        "__typename": "Human",
        "nestedList": [[]]
      ],
      variables: nil
    ))

    // when
    let actual = Hero(data: DataDict(object, variables: nil))

    // then
    expect(actual.nestedList).to(equal([[expected]]))
  }

  func test__selection__nestedArrayOfEntity_nullableInnerList_givenValue__returnsValue() {
    // given
    class Hero: MockSelectionSet, SelectionSet {
      typealias Schema = MockSchemaConfiguration

      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .field("nestedList", [[Hero]?].self)
      ]}

      var nestedList: [[Hero]?] { data["nestedList"] }
    }

    let object: JSONObject = [
      "__typename": "Human",
      "nestedList": [[
        [
          "__typename": "Human",
          "nestedList": [[]]
        ]
      ]]
    ]

    let expected = Hero(data: DataDict(
      [
        "__typename": "Human",
        "nestedList": [[]]
      ],
      variables: nil
    ))

    // when
    let actual = Hero(data: DataDict(object, variables: nil))

    // then
    expect(actual.nestedList).to(equal([[expected]]))
  }

  func test__selection__nestedArrayOfEntity_nullableInnerList_givenNilValues__returnsListWithNils() {
    // given
    class Hero: MockSelectionSet, SelectionSet {
      typealias Schema = MockSchemaConfiguration

      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .field("nestedList", [[Hero]?].self)
      ]}

      var nestedList: [[Hero]?] { data["nestedList"] }
    }

    let nestedObjectData: JSONObject = [
      "__typename": "Human",
      "nestedList": [[]]
    ]

    let object: JSONObject = [
      "__typename": "Human",
      "nestedList": [
        [Hero]?.none,
        [nestedObjectData],
        [Hero]?.none,
      ]
    ]

    let expectedItem = Hero(data: DataDict(nestedObjectData, variables: nil))

    // when
    let actual = Hero(data: DataDict(object, variables: nil))

    // then
    expect(actual.nestedList).to(equal([[Hero]?.none, [expectedItem], [Hero]?.none]))
  }

  func test__selection__nestedArrayOfEntity_nullableEntity_givenValue__returnsValue() {
    // given
    class Hero: MockSelectionSet, SelectionSet {
      typealias Schema = MockSchemaConfiguration

      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .field("nestedList", [[Hero?]].self)
      ]}

      var nestedList: [[Hero?]] { data["nestedList"] }
    }

    let object: JSONObject = [
      "__typename": "Human",
      "nestedList": [[
        [
          "__typename": "Human",
          "nestedList": [[]]
        ]
      ]]
    ]

    let expected = Hero(data: DataDict(
      [
        "__typename": "Human",
        "nestedList": [[]]
      ],
      variables: nil
    ))

    // when
    let actual = Hero(data: DataDict(object, variables: nil))

    // then
    expect(actual.nestedList).to(equal([[expected]]))
  }

  func test__selection__nestedArrayOfEntity_nullableOuterList_givenValue__returnsValue() {
    // given
    class Hero: MockSelectionSet, SelectionSet {
      typealias Schema = MockSchemaConfiguration

      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .field("nestedList", [[Hero]]?.self)
      ]}

      var nestedList: [[Hero]]? { data["nestedList"] }
    }

    let object: JSONObject = [
      "__typename": "Human",
      "nestedList": [[
        [
          "__typename": "Human",
          "nestedList": [[]]
        ]
      ]]
    ]

    let expected = Hero(data: DataDict(
      [
        "__typename": "Human",
        "nestedList": [[]]
      ],
      variables: nil
    ))

    // when
    let actual = Hero(data: DataDict(object, variables: nil))

    // then
    expect(actual.nestedList).to(equal([[expected]]))
  }  

  // MARK: TypeCase Conversion Tests

  func test__asInlineFragment_givenObjectType_returnsTypeIfCorrectType() {
    // given
    class Human: Object {
      override class var __typename: StaticString { "Human" }
    }
    class Droid: Object {
      override class var __typename: StaticString { "Droid" }
    }

    MockSchemaConfiguration.stub_objectTypeForTypeName = {
      switch $0 {
      case "Human": return Human.self
      case "Droid": return Droid.self
      default: XCTFail(); return nil
      }
    }

    class Hero: MockSelectionSet, SelectionSet {
      typealias Schema = MockSchemaConfiguration

      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .inlineFragment(AsHuman.self),
        .inlineFragment(AsDroid.self),
      ]}

      var asHuman: AsHuman? { _asInlineFragment() }
      var asDroid: AsDroid? { _asInlineFragment() }

      class AsHuman: MockTypeCase, SelectionSet {
        typealias Schema = MockSchemaConfiguration

        override class var __parentType: ParentType { .Object(Human.self)}
        override class var selections: [Selection] {[
          .field("name", String.self)
        ]}
      }

      class AsDroid: MockTypeCase, SelectionSet {
        typealias Schema = MockSchemaConfiguration

        override class var __parentType: ParentType { .Object(Droid.self)}
        override class var selections: [Selection] {[
          .field("primaryFunction", String.self)
        ]}
      }
    }

    let object: JSONObject = [
      "__typename": "Droid",
      "name": "R2-D2"
    ]

    // when
    let actual = Hero(data: DataDict(object, variables: nil))

    // then
    expect(actual.asHuman).to(beNil())
    expect(actual.asDroid).toNot(beNil())
  }

  func test__asInlineFragment_givenInterfaceType_typeForTypeNameImplementsInterface_returnsType() {
    // given
    class Humanoid: Interface { }
    class Human: Object {
      override class var __typename: StaticString { "Human" }
      override public class var __implementedInterfaces: [Interface.Type]? { _implementedInterfaces }
      private static let _implementedInterfaces: [Interface.Type]? = [
        Humanoid.self
      ]
    }

    MockSchemaConfiguration.stub_objectTypeForTypeName = {
      switch $0 {
      case "Human": return Human.self
      default: XCTFail(); return nil
      }
    }

    class Hero: MockSelectionSet, SelectionSet {
      typealias Schema = MockSchemaConfiguration

      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .inlineFragment(AsHumanoid.self),
      ]}

      var asHumanoid: AsHumanoid? { _asInlineFragment() }

      class AsHumanoid: MockTypeCase, SelectionSet {
        typealias Schema = MockSchemaConfiguration

        override class var __parentType: ParentType { .Interface(Humanoid.self)}
        override class var selections: [Selection] {[
          .field("name", String.self)
        ]}
      }

    }

    let object: JSONObject = [
      "__typename": "Human",
      "name": "Han Solo"
    ]

    // when
    let actual = Hero(data: DataDict(object, variables: nil))

    // then
    expect(actual.asHumanoid).toNot(beNil())
  }

  func test__asInlineFragment_givenInterfaceType_typeForTypeNameDoesNotImplementInterface_returnsNil() {
    // given
    class Humanoid: Interface { }
    class Droid: Object {
      override class var __typename: StaticString { "Droid" }
    }

    MockSchemaConfiguration.stub_objectTypeForTypeName = {
      switch $0 {
      case "Droid": return Droid.self
      default: XCTFail(); return nil
      }
    }

    class Hero: MockSelectionSet, SelectionSet {
      typealias Schema = MockSchemaConfiguration

      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .inlineFragment(AsHumanoid.self),
      ]}

      var asHumanoid: AsHumanoid? { _asInlineFragment() }

      class AsHumanoid: MockTypeCase, SelectionSet {
        typealias Schema = MockSchemaConfiguration

        override class var __parentType: ParentType { .Interface(Humanoid.self)}
        override class var selections: [Selection] {[
          .field("name", String.self)
        ]}
      }

    }

    let object: JSONObject = [
      "__typename": "Droid",
      "name": "R2-D2"
    ]

    // when
    let actual = Hero(data: DataDict(object, variables: nil))

    // then
    expect(actual.asHumanoid).to(beNil())
  }

  func test__asInlineFragment_givenUnionType_typeNameIsTypeInUnionPossibleTypes_returnsType() {
    // given
    class Human: Object {
      override class var __typename: StaticString { "Human" }
    }

    struct Character: Union {
      let object: Object

      init(_ object: Object) {
        self.object = object
      }

      static let possibleTypes: [Object.Type] = [Human.self]
    }

    MockSchemaConfiguration.stub_objectTypeForTypeName = {
      switch $0 {
      case "Human": return Human.self
      default: XCTFail(); return nil
      }
    }

    class Hero: MockSelectionSet, SelectionSet {
      typealias Schema = MockSchemaConfiguration

      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .inlineFragment(AsCharacter.self),
      ]}

      var asCharacter: AsCharacter? { _asInlineFragment() }

      class AsCharacter: MockTypeCase, SelectionSet {
        typealias Schema = MockSchemaConfiguration

        override class var __parentType: ParentType { .Union(Character.self)}
        override class var selections: [Selection] {[
          .field("name", String.self)
        ]}
      }
    }

    let object: JSONObject = [
      "__typename": "Human",
      "name": "Han Solo"
    ]

    // when
    let actual = Hero(data: DataDict(object, variables: nil))

    // then
    expect(actual.asCharacter).toNot(beNil())
  }

  func test__asInlineFragment_givenUnionType_typeNameNotIsTypeInUnionPossibleTypes_returnsNil() {
    // given
    class Human: Object {
      override class var __typename: StaticString { "Human" }
    }

    struct Character: Union {
      let object: Object

      init(_ object: Object) {
        self.object = object
      }

      static let possibleTypes: [Object.Type] = []
    }

    MockSchemaConfiguration.stub_objectTypeForTypeName = {
      switch $0 {
      case "Human": return Human.self
      default: XCTFail(); return nil
      }
    }

    class Hero: MockSelectionSet, SelectionSet {
      typealias Schema = MockSchemaConfiguration

      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .inlineFragment(AsCharacter.self),
      ]}

      var asCharacter: AsCharacter? { _asInlineFragment() }

      class AsCharacter: MockTypeCase, SelectionSet {
        typealias Schema = MockSchemaConfiguration

        override class var __parentType: ParentType { .Union(Character.self)}
        override class var selections: [Selection] {[
          .field("name", String.self)
        ]}
      }
    }

    let object: JSONObject = [
      "__typename": "Human",
      "name": "Han Solo"
    ]

    // when
    let actual = Hero(data: DataDict(object, variables: nil))

    // then
    expect(actual.asCharacter).to(beNil())
  }

}