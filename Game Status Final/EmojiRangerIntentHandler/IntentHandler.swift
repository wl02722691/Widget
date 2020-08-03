/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A custom intent handler that provides a dynamic list of available characters.
*/

import Intents

class IntentHandler: INExtension, DynamicCharacterSelectionIntentHandling {
    //19: dynamic set of option, 這是 asynchronous call 像是 timeline method
    //20. update widget 從 dynamic intent
    func provideHeroOptionsCollection(for intent: DynamicCharacterSelectionIntent,
                                      with completion: @escaping (INObjectCollection<Hero>?, Error?) -> Void) {
        let characters: [Hero] = CharacterDetail.availableCharacters.map { character in
            let hero = Hero(identifier: character.name, display: character.name)
            
            return hero
        }
        
        let remoteCharacters: [Hero] = CharacterDetail.remoteCharacters.map { character in
            let hero = Hero(identifier: character.name, display: character.name)
            
            return hero
        }
        
        let collection = INObjectCollection(items: characters + remoteCharacters)
        
        completion(collection, nil)
    }
    
    override func handler(for intent: INIntent) -> Any {
        return self
    }
}
