package still88.backend.dto.user;

import jakarta.persistence.Column;
import lombok.*;

@Getter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class GetUserDetailResponseDto {


    private String userNickname;

    private int userAge;

    private Boolean userGender;

    private String userImage;

    private Boolean alarm;

    private String secretEmail;
}
