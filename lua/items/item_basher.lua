--[[ ============================================================================================================
	Author: Rook
	Date: February 1, 2015
	Called when a unit with Skull Basher lands an attack.  Calculates whether a stun should occur, and applies one
	if so.
	Additional parameters: keys.BashChanceMelee and keys.BashChanceRanged
================================================================================================================= ]]
function modifier_item_basher_datadriven_bash_chance_on_attack_landed(keys)
	if not keys.caster:HasModifier("bash_cooldown_modifier") then
		local random_int = RandomInt(1, 100)
		local is_ranged_attacker = keys.caster:IsRangedAttacker()
		
		if (is_ranged_attacker and random_int <= keys.BashChanceRanged) or (not is_ranged_attacker and random_int <= keys.BashChanceMelee) then
			keys.target:EmitSound("DOTA_Item.SkullBasher")
			keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_item_basher_datadriven_bash", nil)
			keys.ability:StartCooldown(keys.ability:GetCooldown(keys.ability:GetLevel()))  --This is just for visual purposes.
			
			--Give the caster a generic "bash cooldown" modifier so they cannot bash in the next couple of seconds due to any item.
			keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "bash_cooldown_modifier", nil)
		end
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: February 1, 2015
	Called when a bash chance modifier is created or destroyed on the unit.  Ensures that only one of these modifiers
	is active on the unit, since they should not stack.
================================================================================================================= ]]
function modifier_item_basher_datadriven_recalculate_bash_chance(keys)
	Timers:CreateTimer({
		callback = function()
			--Temporarily remove all Skull Basher and Abyssal Blade bash chance modifiers.
			while keys.caster:HasModifier("modifier_item_basher_datadriven_bash_chance") do
				keys.caster:RemoveModifierByName("modifier_item_basher_datadriven_bash_chance")
			end
			while keys.caster:HasModifier("modifier_item_abyssal_blade_datadriven_bash_chance") do
				keys.caster:RemoveModifierByName("modifier_item_abyssal_blade_datadriven_bash_chance")
			end

			--Find out if there is a Skull Basher or Abyssal Blade in the player's inventory.
			local skull_basher = nil
			local abyssal_blade = nil
			for i=0, 5, 1 do
				local current_item = keys.caster:GetItemInSlot(i)
				if current_item ~= nil then
					local item_name = current_item:GetName()
					if item_name == "item_basher_datadriven" then
						skull_basher = current_item
					elseif item_name == "item_abyssal_blade_datadriven" then
						abyssal_blade = current_item
					end
				end
			end
			
			if abyssal_blade ~= nil then  --Prioritize the Abyssal Blade bash chance modifier.
				abyssal_blade:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_item_abyssal_blade_datadriven_bash_chance", {duration = -1})
			elseif skull_basher ~= nil then
				skull_basher:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_item_basher_datadriven_bash_chance", {duration = -1})
			end
		end
	})
end
function item_basher:GetAbilityTextureName() return self.BaseClass.GetAbilityTextureName(self)  end 

