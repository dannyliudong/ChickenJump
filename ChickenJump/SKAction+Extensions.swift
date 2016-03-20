/*
 * Copyright (c) 2013-2014 Razeware LLC
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import SpriteKit

public extension SKAction {
  /**
   * Performs an action after the specified delay.
   */
  public class func afterDelay(delay: NSTimeInterval, performAction action: SKAction) -> SKAction {
    return SKAction.sequence([SKAction.waitForDuration(delay), action])
  }

  /**
   * Performs a block after the specified delay.
   */
  public class func afterDelay(delay: NSTimeInterval, runBlock block: dispatch_block_t) -> SKAction {
    return SKAction.afterDelay(delay, performAction: SKAction.runBlock(block))
  }

  /**
   * Removes the node from its parent after the specified delay.
   */
  public class func removeFromParentAfterDelay(delay: NSTimeInterval) -> SKAction {
    return SKAction.afterDelay(delay, performAction: SKAction.removeFromParent())
  }

  /**
   * Creates an action to perform a parabolic jump.
   */
  public class func jumpToHeight(height: CGFloat, duration: NSTimeInterval, originalPosition: CGPoint) -> SKAction {
    return SKAction.customActionWithDuration(duration) {(node, elapsedTime) in
      let fraction = elapsedTime / CGFloat(duration)
      let yOffset = height * 4 * fraction * (1 - fraction)
      node.position = CGPoint(x: originalPosition.x, y: originalPosition.y + yOffset)
    }
  }
    
  public class func moveToY_Cycle(distance:CGFloat, time:NSTimeInterval) ->SKAction {
    
        let moveUp = SKAction.moveBy(CGVectorMake(0, distance), duration: time)
        let moveDown = SKAction.moveBy(CGVectorMake(0, -distance), duration: time)
    
    
        
        return SKAction.repeatActionForever(SKAction.sequence([moveUp, moveDown]))
    }
    
    public class func moveToY_Cycle_ChangeDirection(distance:CGFloat, time:NSTimeInterval) ->SKAction {
        
        let moveUp = SKAction.moveBy(CGVectorMake(0, distance), duration: time)
        let moveDown = SKAction.moveBy(CGVectorMake(0, -distance), duration: time)
        
        let changedirectionUp:SKAction = SKAction.scaleYTo(-1, duration: 0.0)
        let changedirectionDown:SKAction = SKAction.scaleYTo(1, duration: 0.0)
        
        
        return SKAction.repeatActionForever(SKAction.sequence([moveUp, changedirectionUp, moveDown, changedirectionDown]))
    }
    
    
  public class func moveToX_Cycle(distance:CGFloat, time:NSTimeInterval) ->SKAction{
        
        let moveUp = SKAction.moveBy(CGVectorMake(distance, 0), duration: time)
        let moveDown = SKAction.moveBy(CGVectorMake(-distance, 0), duration: time)
        
        return SKAction.repeatActionForever(SKAction.sequence([moveUp, moveDown]))
    }
    
    /**
     移动一段距离 然后淡出消失
     - distance : 要移动的距离
     - time: 移动所需时间
     - delay: 完成后 延迟消失时间
     */
    public class func moveAnimationToDisappear(distance:CGFloat, waitTime:NSTimeInterval, removeDelay:NSTimeInterval) ->SKAction {
        // 透明度变化
        // 淡入
        let fadein = SKAction.fadeAlphaTo(0.2, duration: 1.0)
        // 等待
        let wait = SKAction.waitForDuration(waitTime)
        // 淡出
        let fadeout = SKAction.fadeAlphaTo(0.0, duration: 1.0)
        
        // 位置变化
        let move = SKAction.moveBy(CGVectorMake(distance, 0), duration: waitTime + 2)
        let done = SKAction.removeFromParentAfterDelay(removeDelay)
        
        let sequence1 = SKAction.sequence([fadein, wait, fadeout])
        
        let sequence2 = SKAction.sequence([move, done])
        
        return SKAction.repeatActionForever(SKAction.group([sequence1, sequence2]))
        
    }

}
