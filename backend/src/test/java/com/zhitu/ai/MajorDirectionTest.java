package com.zhitu.ai;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 专业方向识别与降级内容测试。
 *
 * 真实故障：未配置 API Key 时走规则降级，而原来的降级内容是按计算机专业写死的，
 * 于是土木工程的学生拿到了「C语言 / 数据结构 / 蓝桥杯」，完全没有参考价值。
 */
class MajorDirectionTest {

    @Test
    void civilEngineeringGetsCivilContent() {
        MajorDirection direction = MajorDirection.resolve("土木工程");

        assertThat(direction.label()).isEqualTo("土木 / 建筑类");
        assertThat(direction.years()[0].courses).contains("理论力学", "工程制图");
        // 关键：不能再出现计算机方向的课程与竞赛
        assertThat(direction.years()[0].courses).doesNotContain("C语言程序设计");
        assertThat(direction.years()[1].courses).doesNotContain("数据结构");
        assertThat(direction.suggestions().toString()).doesNotContain("蓝桥杯");
        assertThat(direction.years()[2].competitions.toString()).doesNotContain("ACM");
    }

    @Test
    void computerScienceStillGetsItContent() {
        MajorDirection direction = MajorDirection.resolve("计算机科学与技术");

        assertThat(direction.label()).isEqualTo("计算机 / 电子信息");
        assertThat(direction.years()[0].courses).contains("C语言程序设计");
        assertThat(direction.suggestions().toString()).contains("蓝桥杯");
    }

    @Test
    void clinicalMedicineGetsMedicalContent() {
        MajorDirection direction = MajorDirection.resolve("临床医学");

        assertThat(direction.label()).isEqualTo("医学类");
        assertThat(direction.years()[0].courses).contains("人体解剖学", "生理学");
        assertThat(direction.certificates().toString()).contains("执业医师");
    }

    @Test
    void automationIsEngineeringNotCivil() {
        // 「自动化」容易被土木的正则误伤，这里单独守一下
        MajorDirection direction = MajorDirection.resolve("自动化");
        assertThat(direction.label()).isEqualTo("机电 / 自动化 / 材料类");
    }

    @Test
    void financeGoesToBusiness() {
        assertThat(MajorDirection.resolve("金融学").label()).isEqualTo("经管类");
    }

    @Test
    void chineseLanguageGoesToHumanities() {
        assertThat(MajorDirection.resolve("汉语言文学").label()).isEqualTo("人文社科");
        // 外语专业独立成方向：英语拿到的是外语类内容，而不是汉语言文学的课程
        assertThat(MajorDirection.resolve("英语").label()).isEqualTo("外语类");
        assertThat(MajorDirection.resolve("商务英语").label()).isEqualTo("外语类");
        assertThat(MajorDirection.resolve("日语").label()).isEqualTo("外语类");
    }

    @Test
    void unknownMajorFallsBackToGeneral() {
        MajorDirection direction = MajorDirection.resolve("某个不存在的专业");

        assertThat(direction.label()).isEqualTo("通用");
        // 兜底模板可以讲通用方法，但不能编造具体专业内容
        assertThat(direction.years()[0].courses).doesNotContain("C语言程序设计");
        assertThat(direction.years().length).isEqualTo(4);
    }

    @Test
    void everyDirectionHasCompleteFourYearPlan() {
        String[] majors = {"计算机科学与技术", "土木工程", "机械设计制造及其自动化", "临床医学",
                           "会计学", "法学", "学前教育", "视觉传达设计", "农学", "数学与应用数学",
                           "汉语言文学", "未知专业"};

        for (String major : majors) {
            MajorDirection direction = MajorDirection.resolve(major);
            assertThat(direction.years()).as(major + " 的四年规划").hasSize(4);
            for (MajorDirection.YearPlan year : direction.years()) {
                assertThat(year.theme).as(major + " 的阶段主题").isNotBlank();
                assertThat(year.goals).as(major + " 的目标").isNotEmpty();
                assertThat(year.courses).as(major + " 的课程").isNotEmpty();
                assertThat(year.tips).as(major + " 的建议").isNotBlank();
            }
            assertThat(direction.suggestions()).as(major + " 的画像建议").isNotEmpty();
            assertThat(direction.risks()).as(major + " 的风险提醒").isNotEmpty();
            assertThat(direction.certificates()).as(major + " 的证书推荐").isNotEmpty();
            assertThat(direction.positions()).as(major + " 的就业岗位").isNotEmpty();
        }
    }

    @Test
    void nursingDoesNotGetProgrammerPositions() {
        // 简历的「意向岗位」以前写死「Java后端开发工程师」，护理学学生拿到就是跑偏的
        assertThat(MajorDirection.resolve("护理学").positions())
            .contains("临床护士")
            .noneMatch(p -> p.contains("Java") || p.contains("开发工程师"));
    }

    @Test
    void businessAndAnimalGetTheirOwnPositions() {
        assertThat(MajorDirection.resolve("会计学").positions()).contains("会计");
        assertThat(MajorDirection.resolve("动物医学").positions())
            .anyMatch(p -> p.contains("动物") || p.contains("兽医") || p.contains("宠物"));
    }

    @Test
    void isGeneralOnlyForUnrecognisedMajors() {
        assertThat(MajorDirection.resolve("护理学").isGeneral()).isFalse();
        assertThat(MajorDirection.resolve("会计学").isGeneral()).isFalse();
        // 认不出来的专业才会落到通用兜底——竞赛匹配时要靠这个把误判挡掉
        assertThat(MajorDirection.resolve("某个不存在的专业").isGeneral()).isTrue();
        assertThat(MajorDirection.resolve("").isGeneral()).isTrue();
    }
}
