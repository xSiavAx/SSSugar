import XCTest

@testable import SSSugar

class SSSugarContainersAutoMapTests: XCTestCase {
    public var automap : AutoMap<String, Set<Int>>!
    
//    Тесты с сетом
//
//    Инициализация с картой. С обычной кратой. С пустой картой. С картой с пустыми контейнерами.
//    Содержание. В пустом контейнере, с нужным ключем без элемента, без нужного ключа с элементом, с нужным ключем с нужным элементом.
//    Получение контейнера. Получение контейнера по ключу. Получение контейнера по ключу которого нет.
//    Добавление контейнера. В пустую карту. В непустую карту. В карту содержащую ключ.
//    Добавление. В пустую автокарту. С новым ключем. С существующим ключем. Добавление в разном порядке.
//    Замена контейнера. Обычная замена. Пустым контейнером. По ключу которого не было.
//    Удаление контейнера. По существующему ключу. По ключу, которого нет.
//    Удаление элемента. По ключу котрого нет. По существующему ключу без элемента. По существующему ключу.
//    Удаление всех элментов. С пустой карты. С наполненной карты.
//    subscript get. Обычное получение. По ключу которого не было.
//    subscript set. Обычная запись. Пустым контейнером. По ключу которого не было.
//
//    Тесты с массивом
//
//    Получение елемента. По ключу и индексу. По ключу которого нет. По индексу которого нет. По ключу и индексу которых нет.
//    Вставка. Вставка по ключу которого нет. С индексом в начале. С индексом в конце. С индексом в средине. С индексом которого нет.
//    Обновление. По ключу и индексу. По ключу которого нет. По индексу которого нет. По ключу и индексу которых нет.
//    Удаление. По ключу и индексу. По ключу которого нет. По индексу которого нет. По ключу и индеку которых нет.
//    Множественное удаление. С ключами и ндексами. С ключами которые частично есть. С ключами которых нет вовсе. С индексами которых нет.
//    subscript. get. По ключу и индексу. По ключу которого нет. По индексу которого нет. По ключу и индексу которых нет.
//    subscript. set. По ключу и индексу. По ключу которого нет. По индексу которого нет. По ключу и индексу которых нет.
    
    override func setUp() {
         automap = AutoMap<String, Set<Int>>()
    }

    override func tearDown() {
        automap = nil
    }
    
    func checkWith(dict : [String : Set<Int>]) {
        XCTAssertEqual(automap.keys, dict.keys)
        
        for key in automap.keys {
            XCTAssertEqual(automap[key], dict[key])
        }
    }
}