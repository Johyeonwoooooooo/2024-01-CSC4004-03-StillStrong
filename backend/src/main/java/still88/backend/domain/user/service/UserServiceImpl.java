package still88.backend.domain.user.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import still88.backend.dto.user.*;
import still88.backend.entity.IdPassword;
import still88.backend.entity.Recipe;
import still88.backend.entity.User;
import still88.backend.repository.IdPasswordRepository;
import still88.backend.repository.IngredientRepository;
import still88.backend.repository.RecipeRepository;
import still88.backend.repository.UserRepository;

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {
    private final UserRepository userRepository;
    private final IngredientRepository ingredientRepository;
    private final IdPasswordRepository idPasswordRepository;
    private final RecipeRepository recipeRepository;
    private final ObjectMapper objectMapper = new ObjectMapper();

    public GetUserDetailResponseDto getUserDetail(int userId) {
        User user = userRepository.findUserByUserId(userId);
        if(user == null)
            throw new IllegalArgumentException("User not found with id: " + userId);

        IdPassword idPassword = idPasswordRepository.findIdPasswordByUser(user);
        if (user == null)
            throw new IllegalArgumentException("IdPassword not found with id, : " + user);

        return GetUserDetailResponseDto.builder()
                .userNickname(user.getUserNickname())
                .userGender(user.getUserGender())
                .userAge(user.getUserAge())
                .alarm(user.getAlarm())
                .userImage(user.getUserImage())
                .secretEmail(idPassword.getSecretEmail())
                .build();
    }

    public GetUserDetailResponseDto updateUserDetail(int userId, UpdateUserDetailRequestDto updateUserDetailRequestDto) {
        User user = userRepository.findUserByUserId(userId);
        if(user == null)
            throw new IllegalArgumentException("User not found with id: " + userId);

        IdPassword idPassword = idPasswordRepository.findIdPasswordByUser(user);
        if (user == null)
            throw new IllegalArgumentException("IdPassword not found with id, : " + user);

        user.updateInfo(updateUserDetailRequestDto.getUserNickname(),
                updateUserDetailRequestDto.getUserAge(),
                updateUserDetailRequestDto.getUserGender(),
                updateUserDetailRequestDto.getUserImage(),
                updateUserDetailRequestDto.getAlarm());
        idPassword.updateEmail(updateUserDetailRequestDto.getSecretEmail());

        User updatedUser = userRepository.save(user);
        IdPassword updatedIdPassword = idPasswordRepository.save(idPassword);

        return GetUserDetailResponseDto.builder()
                .userNickname(updatedUser.getUserNickname())
                .userAge(updatedUser.getUserAge())
                .userGender(updatedUser.getUserGender())
                .userImage(updatedUser.getUserImage())
                .alarm(updatedUser.getAlarm())
                .secretEmail(updatedIdPassword.getSecretEmail())
                .build();

    }

    public void registerFavorite(int userId, RegisterFavoriteRequestDto registerFavoriteRequestDto) {
        Optional<User> userO = userRepository.findById((long) userId);
        if (userO.isPresent()) {
            User user = userO.get();
            List<String> favorites = List.of(registerFavoriteRequestDto.getFavorites());
            List<Integer> recipeIds = new ArrayList<>();

            // Fetch recipe IDs for each category
            for (String category : favorites) {
                List<Recipe> recipes = recipeRepository.findRecipeIdByRecipeCategory(category);
                List<Integer> categoryRecipeIds = recipes.stream().map(Recipe::getRecipeId).collect(Collectors.toList());
                recipeIds.addAll(categoryRecipeIds);
            }

            try {
                String favoritesJson = objectMapper.writeValueAsString(recipeIds);
                user.registerFavorite(favoritesJson);
                userRepository.save(user);
            } catch (Exception e) {
                throw new RuntimeException("Failed to convert favorites to JSON", e);
            }
        } else {
            throw new IllegalArgumentException("존재하지 않는 사용자입니다!");
        }
    }

    public void registerAllergy(int userId, RegisterAllergyRequestDto registerAllergyRequestDto) {
        Optional<User> userO = userRepository.findById((long) userId);
        if (userO.isPresent()) {
            User user = userO.get();
            List<String> allergies = List.of(registerAllergyRequestDto.getAllergies());

            try {
                String allergyJson = objectMapper.writeValueAsString(allergies);
                user.registerAllergy(allergyJson);
                userRepository.save(user);
            } catch (Exception e) {
                throw new RuntimeException("Failed to convert allergies to JSON", e);
            }
        } else {
            throw new IllegalArgumentException("존재하지 않는 사용자입니다!");
        }
    }

    @Override
    public GetAllergyListResponseDTO getAllergyList() {
        return GetAllergyListResponseDTO.builder()
                .allergies(ingredientRepository.getAllAllergyInfo())
                .build();
    }

    public GetAllergyResponseDto getUserAllergry(int userId) {
        Optional<User> userO = userRepository.findById((long) userId);
        if (userO.isPresent()) {
            User user = userO.get();
            String allergyJson = user.getUserAllergy();
            if (allergyJson != null) {
                try {
                    List<String> allergies = objectMapper.readValue(allergyJson, new TypeReference<List<String>>() {});
                    return new GetAllergyResponseDto(allergies);
                } catch (Exception e) {
                    throw new RuntimeException("Failed to parse allergy JSON", e);
                }
            } else {
                return new GetAllergyResponseDto(Collections.emptyList());
            }
        } else {
            throw new IllegalArgumentException("존재하지 않는 사용자입니다!");
        }

    }
}