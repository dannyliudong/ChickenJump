// ---------------------------------------
// Sprite definitions for 'POCRunTextureAlats'
// Generated with TexturePacker 4.0.1
//
// http://www.codeandweb.com/texturepacker
// ---------------------------------------

import SpriteKit


class POCRunTextureAlats {

    // sprite names
    let POCRUNING1  = "PocRuning1"
    let POCRUNING10 = "PocRuning10"
    let POCRUNING11 = "PocRuning11"
    let POCRUNING12 = "PocRuning12"
    let POCRUNING13 = "PocRuning13"
    let POCRUNING2  = "PocRuning2"
    let POCRUNING3  = "PocRuning3"
    let POCRUNING4  = "PocRuning4"
    let POCRUNING5  = "PocRuning5"
    let POCRUNING6  = "PocRuning6"
    let POCRUNING7  = "PocRuning7"
    let POCRUNING8  = "PocRuning8"
    let POCRUNING9  = "PocRuning9"


    // load texture atlas
    let textureAtlas = SKTextureAtlas(named: "POCRunTextureAlats")


    // individual texture objects
    func PocRuning1() -> SKTexture  { return textureAtlas.textureNamed(POCRUNING1) }
    func PocRuning10() -> SKTexture { return textureAtlas.textureNamed(POCRUNING10) }
    func PocRuning11() -> SKTexture { return textureAtlas.textureNamed(POCRUNING11) }
    func PocRuning12() -> SKTexture { return textureAtlas.textureNamed(POCRUNING12) }
    func PocRuning13() -> SKTexture { return textureAtlas.textureNamed(POCRUNING13) }
    func PocRuning2() -> SKTexture  { return textureAtlas.textureNamed(POCRUNING2) }
    func PocRuning3() -> SKTexture  { return textureAtlas.textureNamed(POCRUNING3) }
    func PocRuning4() -> SKTexture  { return textureAtlas.textureNamed(POCRUNING4) }
    func PocRuning5() -> SKTexture  { return textureAtlas.textureNamed(POCRUNING5) }
    func PocRuning6() -> SKTexture  { return textureAtlas.textureNamed(POCRUNING6) }
    func PocRuning7() -> SKTexture  { return textureAtlas.textureNamed(POCRUNING7) }
    func PocRuning8() -> SKTexture  { return textureAtlas.textureNamed(POCRUNING8) }
    func PocRuning9() -> SKTexture  { return textureAtlas.textureNamed(POCRUNING9) }


    // texture arrays for animations
    func PocRuning() -> [SKTexture] {
        return [
            PocRuning1(),
            PocRuning2(),
            PocRuning3(),
            PocRuning4(),
            PocRuning5(),
            PocRuning6(),
            PocRuning7(),
            PocRuning8(),
            PocRuning9(),
            PocRuning10(),
            PocRuning11(),
            PocRuning12(),
            PocRuning13()
        ]
    }


}
